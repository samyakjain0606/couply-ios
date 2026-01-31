import Foundation
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

    // MARK: - Initialization
    private init() {
        // Demo mode - no Firebase needed
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second splash
            isLoading = false
        }
    }

    // MARK: - Phone Authentication (Demo)
    func sendVerificationCode(to phoneNumber: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        return "demo-verification-id"
    }

    func verifyCode(_ code: String, verificationID: String) async throws {
        // Simulate verification
        try await Task.sleep(nanoseconds: 500_000_000)

        // Create demo user
        currentUser = User(
            id: "demo-user-123",
            phoneNumber: "+1234567890",
            displayName: "You"
        )
        isAuthenticated = true
    }

    // MARK: - Profile Update
    func updateProfile(displayName: String, avatarURL: String? = nil) async throws {
        currentUser?.displayName = displayName
        currentUser?.avatarURL = avatarURL
    }

    func updateMood(_ mood: Mood) async throws {
        currentUser?.currentMood = mood
    }

    func updateFCMToken(_ token: String) async {
        // No-op in demo mode
    }

    // MARK: - Sign Out
    func signOut() throws {
        currentUser = nil
        partner = nil
        couple = nil
        isAuthenticated = false
    }

    // MARK: - Demo: Connect with Partner
    func connectWithPartner() {
        partner = User(
            id: "demo-partner-456",
            phoneNumber: "+0987654321",
            displayName: "Partner",
            partnerID: "demo-user-123",
            coupleID: "demo-couple-789"
        )

        couple = Couple(
            id: "demo-couple-789",
            user1ID: "demo-user-123",
            user2ID: "demo-partner-456",
            streakCount: 7,
            totalPhotosExchanged: 42
        )

        currentUser?.partnerID = "demo-partner-456"
        currentUser?.coupleID = "demo-couple-789"
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
