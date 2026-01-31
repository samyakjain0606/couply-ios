import Foundation
import FirebaseFirestore

@MainActor
class PairingService: ObservableObject {
    static let shared = PairingService()

    // MARK: - Published Properties
    @Published var currentInviteCode: InviteCode?
    @Published var isWaitingForPartner = false
    @Published var error: PairingError?

    // MARK: - Private Properties
    private let db = Firestore.firestore()
    private var inviteListener: ListenerRegistration?

    private init() {}

    // MARK: - Generate Invite Code
    func generateInviteCode() async throws -> InviteCode {
        guard let userID = AuthService.shared.currentUser?.id else {
            throw PairingError.notAuthenticated
        }

        // Check if user already has an active invite
        let existingQuery = try await db.collection("invites")
            .whereField("creatorID", isEqualTo: userID)
            .whereField("usedBy", isEqualTo: NSNull())
            .getDocuments()

        // Delete old invites
        for doc in existingQuery.documents {
            try await doc.reference.delete()
        }

        // Generate new invite code
        let invite = InviteCode.generate(for: userID)

        // Save to Firestore
        try await db.collection("invites").document(invite.code).setData([
            "code": invite.code,
            "creatorID": invite.creatorID,
            "createdAt": Timestamp(date: invite.createdAt),
            "expiresAt": Timestamp(date: invite.expiresAt)
        ])

        currentInviteCode = invite
        isWaitingForPartner = true

        // Listen for when partner uses the code
        setupInviteListener(code: invite.code)

        return invite
    }

    // MARK: - Join with Invite Code
    func joinWithCode(_ code: String) async throws {
        guard let userID = AuthService.shared.currentUser?.id else {
            throw PairingError.notAuthenticated
        }

        let inviteRef = db.collection("invites").document(code.uppercased())
        let inviteDoc = try await inviteRef.getDocument()

        guard inviteDoc.exists else {
            throw PairingError.invalidCode
        }

        guard let data = inviteDoc.data(),
              let creatorID = data["creatorID"] as? String,
              let expiresAtTimestamp = data["expiresAt"] as? Timestamp else {
            throw PairingError.invalidCode
        }

        // Check if code is expired
        let expiresAt = expiresAtTimestamp.dateValue()
        if Date() > expiresAt {
            throw PairingError.codeExpired
        }

        // Check if code is already used
        if data["usedBy"] != nil {
            throw PairingError.codeAlreadyUsed
        }

        // Check user isn't trying to use their own code
        if creatorID == userID {
            throw PairingError.cannotUseSelf
        }

        // Create the couple connection
        try await createCouple(user1ID: creatorID, user2ID: userID)

        // Mark invite as used
        try await inviteRef.updateData([
            "usedBy": userID,
            "usedAt": Timestamp(date: Date())
        ])
    }

    // MARK: - Create Couple Connection
    private func createCouple(user1ID: String, user2ID: String) async throws {
        let batch = db.batch()

        // Create couple document
        let coupleRef = db.collection("couples").document()
        let coupleID = coupleRef.documentID

        let couple = Couple(
            id: coupleID,
            user1ID: user1ID,
            user2ID: user2ID
        )

        batch.setData(couple.dictionary, forDocument: coupleRef)

        // Update user1
        let user1Ref = db.collection("users").document(user1ID)
        batch.updateData([
            "partnerID": user2ID,
            "coupleID": coupleID
        ], forDocument: user1Ref)

        // Update user2
        let user2Ref = db.collection("users").document(user2ID)
        batch.updateData([
            "partnerID": user1ID,
            "coupleID": coupleID
        ], forDocument: user2Ref)

        // Commit all changes atomically
        try await batch.commit()

        // Post notification
        NotificationCenter.default.post(name: .partnerConnected, object: nil)
    }

    // MARK: - Listen for Partner
    private func setupInviteListener(code: String) {
        inviteListener?.remove()
        inviteListener = db.collection("invites").document(code)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let data = snapshot?.data(),
                      data["usedBy"] != nil else { return }

                Task { @MainActor in
                    self.isWaitingForPartner = false
                    self.currentInviteCode = nil
                    self.inviteListener?.remove()

                    // Post notification that partner connected
                    NotificationCenter.default.post(name: .partnerConnected, object: nil)
                }
            }
    }

    // MARK: - Cancel Waiting
    func cancelWaiting() {
        inviteListener?.remove()
        isWaitingForPartner = false
        currentInviteCode = nil
    }

    // MARK: - Disconnect Partner
    func disconnectPartner() async throws {
        guard let userID = AuthService.shared.currentUser?.id,
              let partnerID = AuthService.shared.currentUser?.partnerID,
              let coupleID = AuthService.shared.currentUser?.coupleID else {
            throw PairingError.notConnected
        }

        let batch = db.batch()

        // Remove couple document
        let coupleRef = db.collection("couples").document(coupleID)
        batch.deleteDocument(coupleRef)

        // Update current user
        let userRef = db.collection("users").document(userID)
        batch.updateData([
            "partnerID": FieldValue.delete(),
            "coupleID": FieldValue.delete()
        ], forDocument: userRef)

        // Update partner
        let partnerRef = db.collection("users").document(partnerID)
        batch.updateData([
            "partnerID": FieldValue.delete(),
            "coupleID": FieldValue.delete()
        ], forDocument: partnerRef)

        try await batch.commit()
    }
}

// MARK: - Pairing Errors
enum PairingError: LocalizedError {
    case notAuthenticated
    case invalidCode
    case codeExpired
    case codeAlreadyUsed
    case cannotUseSelf
    case notConnected
    case unknown

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to connect with a partner."
        case .invalidCode:
            return "This invite code is invalid. Please check and try again."
        case .codeExpired:
            return "This invite code has expired. Ask your partner for a new one."
        case .codeAlreadyUsed:
            return "This invite code has already been used."
        case .cannotUseSelf:
            return "You cannot use your own invite code."
        case .notConnected:
            return "You are not connected to a partner."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
