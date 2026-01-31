import Foundation
import Combine

@MainActor
class PairingService: ObservableObject {
    static let shared = PairingService()

    // MARK: - Published Properties
    @Published var currentInviteCode: InviteCode?
    @Published var isWaitingForPartner = false
    @Published var error: PairingError?

    private init() {}

    // MARK: - Generate Invite Code
    func generateInviteCode() async throws -> InviteCode {
        guard let userID = AuthService.shared.currentUser?.id else {
            throw PairingError.notAuthenticated
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        let invite = InviteCode.generate(for: userID)
        currentInviteCode = invite
        isWaitingForPartner = true

        return invite
    }

    // MARK: - Join with Invite Code
    func joinWithCode(_ code: String) async throws {
        guard AuthService.shared.currentUser?.id != nil else {
            throw PairingError.notAuthenticated
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // In demo mode, just connect
        AuthService.shared.connectWithPartner()

        // Post notification
        NotificationCenter.default.post(name: .partnerConnected, object: nil)
    }

    // MARK: - Cancel Waiting
    func cancelWaiting() {
        isWaitingForPartner = false
        currentInviteCode = nil
    }

    // MARK: - Disconnect Partner
    func disconnectPartner() async throws {
        guard AuthService.shared.currentUser?.partnerID != nil else {
            throw PairingError.notConnected
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        AuthService.shared.partner = nil
        AuthService.shared.couple = nil
        AuthService.shared.currentUser?.partnerID = nil
        AuthService.shared.currentUser?.coupleID = nil
    }

    // MARK: - Demo: Simulate Partner Joining
    func simulatePartnerJoining() {
        isWaitingForPartner = false
        currentInviteCode = nil
        AuthService.shared.connectWithPartner()
        NotificationCenter.default.post(name: .partnerConnected, object: nil)
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
