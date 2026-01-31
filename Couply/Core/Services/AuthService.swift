import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()

    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var partner: User?
    @Published var couple: Couple?
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var error: AuthError?

    // MARK: - Private Properties
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?
    private var partnerListener: ListenerRegistration?
    private var coupleListener: ListenerRegistration?

    // MARK: - Initialization
    private init() {
        setupAuthStateListener()
    }

    deinit {
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
        }
        userListener?.remove()
        partnerListener?.remove()
        coupleListener?.remove()
    }

    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let firebaseUser = user {
                    await self?.fetchUserData(uid: firebaseUser.uid)
                } else {
                    self?.clearUserData()
                }
                self?.isLoading = false
            }
        }
    }

    // MARK: - Phone Authentication
    func sendVerificationCode(to phoneNumber: String) async throws -> String {
        do {
            let verificationID = try await PhoneAuthProvider.provider()
                .verifyPhoneNumber(phoneNumber, uiDelegate: nil)
            return verificationID
        } catch {
            throw AuthError.verificationFailed(error.localizedDescription)
        }
    }

    func verifyCode(_ code: String, verificationID: String) async throws {
        let credential = PhoneAuthProvider.provider()
            .credential(withVerificationID: verificationID, verificationCode: code)

        do {
            let result = try await auth.signIn(with: credential)
            await createOrFetchUser(firebaseUser: result.user)
        } catch {
            throw AuthError.invalidCode
        }
    }

    // MARK: - User Management
    private func createOrFetchUser(firebaseUser: FirebaseAuth.User) async {
        let userRef = db.collection("users").document(firebaseUser.uid)

        do {
            let document = try await userRef.getDocument()

            if document.exists {
                // Existing user - fetch data
                await fetchUserData(uid: firebaseUser.uid)
            } else {
                // New user - create document
                let newUser = User(
                    id: firebaseUser.uid,
                    phoneNumber: firebaseUser.phoneNumber ?? "",
                    displayName: ""
                )

                try await userRef.setData(newUser.dictionary)
                currentUser = newUser
                isAuthenticated = true
            }
        } catch {
            self.error = .userCreationFailed
        }
    }

    private func fetchUserData(uid: String) async {
        // Set up real-time listener for user
        userListener?.remove()
        userListener = db.collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching user: \(error)")
                    return
                }

                guard let data = snapshot?.data() else { return }

                Task { @MainActor in
                    self.currentUser = try? snapshot?.data(as: User.self)
                    self.isAuthenticated = true

                    // Set up couple and partner listeners if connected
                    if let coupleID = self.currentUser?.coupleID {
                        await self.setupCoupleListener(coupleID: coupleID)
                    }

                    if let partnerID = self.currentUser?.partnerID {
                        await self.setupPartnerListener(partnerID: partnerID)
                    }
                }
            }
    }

    private func setupCoupleListener(coupleID: String) async {
        coupleListener?.remove()
        coupleListener = db.collection("couples").document(coupleID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                Task { @MainActor in
                    self.couple = try? snapshot?.data(as: Couple.self)
                }
            }
    }

    private func setupPartnerListener(partnerID: String) async {
        partnerListener?.remove()
        partnerListener = db.collection("users").document(partnerID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                Task { @MainActor in
                    self.partner = try? snapshot?.data(as: User.self)
                }
            }
    }

    // MARK: - Profile Update
    func updateProfile(displayName: String, avatarURL: String? = nil) async throws {
        guard let userID = currentUser?.id else {
            throw AuthError.notAuthenticated
        }

        var updates: [String: Any] = [
            "displayName": displayName,
            "lastActive": Timestamp(date: Date())
        ]

        if let avatarURL = avatarURL {
            updates["avatarURL"] = avatarURL
        }

        try await db.collection("users").document(userID).updateData(updates)
    }

    func updateMood(_ mood: Mood) async throws {
        guard let userID = currentUser?.id else {
            throw AuthError.notAuthenticated
        }

        try await db.collection("users").document(userID).updateData([
            "currentMood": mood.rawValue,
            "lastActive": Timestamp(date: Date())
        ])
    }

    func updateFCMToken(_ token: String) async {
        guard let userID = currentUser?.id else { return }

        try? await db.collection("users").document(userID).updateData([
            "fcmToken": token
        ])
    }

    // MARK: - Sign Out
    func signOut() throws {
        try auth.signOut()
        clearUserData()
    }

    private func clearUserData() {
        currentUser = nil
        partner = nil
        couple = nil
        isAuthenticated = false
        userListener?.remove()
        partnerListener?.remove()
        coupleListener?.remove()
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case verificationFailed(String)
    case invalidCode
    case userCreationFailed
    case notAuthenticated
    case unknown

    var errorDescription: String? {
        switch self {
        case .verificationFailed(let message):
            return "Verification failed: \(message)"
        case .invalidCode:
            return "Invalid verification code. Please try again."
        case .userCreationFailed:
            return "Failed to create user account."
        case .notAuthenticated:
            return "You must be signed in to perform this action."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
