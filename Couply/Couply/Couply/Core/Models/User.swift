import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let phoneNumber: String
    var displayName: String
    var avatarURL: String?
    var partnerID: String?
    var coupleID: String?
    var fcmToken: String?
    var currentMood: Mood?
    var lastActive: Date
    let createdAt: Date

    // MARK: - Computed Properties
    var isConnected: Bool {
        coupleID != nil && partnerID != nil
    }

    // MARK: - Initializer
    init(
        id: String? = nil,
        phoneNumber: String,
        displayName: String,
        avatarURL: String? = nil,
        partnerID: String? = nil,
        coupleID: String? = nil,
        fcmToken: String? = nil,
        currentMood: Mood? = nil,
        lastActive: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.partnerID = partnerID
        self.coupleID = coupleID
        self.fcmToken = fcmToken
        self.currentMood = currentMood
        self.lastActive = lastActive
        self.createdAt = createdAt
    }

    // MARK: - Firestore Dictionary
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "phoneNumber": phoneNumber,
            "displayName": displayName,
            "lastActive": Timestamp(date: lastActive),
            "createdAt": Timestamp(date: createdAt)
        ]

        if let avatarURL = avatarURL { dict["avatarURL"] = avatarURL }
        if let partnerID = partnerID { dict["partnerID"] = partnerID }
        if let coupleID = coupleID { dict["coupleID"] = coupleID }
        if let fcmToken = fcmToken { dict["fcmToken"] = fcmToken }
        if let currentMood = currentMood { dict["currentMood"] = currentMood.rawValue }

        return dict
    }
}

// MARK: - Mood Enum
enum Mood: String, Codable, CaseIterable {
    case great = "great"
    case loved = "loved"
    case tired = "tired"
    case sad = "sad"
    case missing = "missing"
    case excited = "excited"

    var emoji: String {
        switch self {
        case .great: return "😊"
        case .loved: return "🥰"
        case .tired: return "😴"
        case .sad: return "😢"
        case .missing: return "🔥"
        case .excited: return "🎉"
        }
    }

    var label: String {
        switch self {
        case .great: return "Great"
        case .loved: return "Loved"
        case .tired: return "Tired"
        case .sad: return "Need a hug"
        case .missing: return "Missing you"
        case .excited: return "Excited"
        }
    }

    var message: String {
        switch self {
        case .great: return "Feeling great!"
        case .loved: return "Feeling loved"
        case .tired: return "Feeling tired"
        case .sad: return "Could use some love"
        case .missing: return "Missing you so much"
        case .excited: return "So excited!"
        }
    }
}

// MARK: - Sample Data
extension User {
    static let sample = User(
        id: "user123",
        phoneNumber: "+15551234567",
        displayName: "Alex",
        avatarURL: nil,
        partnerID: "partner456",
        coupleID: "couple789",
        currentMood: .loved
    )

    static let samplePartner = User(
        id: "partner456",
        phoneNumber: "+15559876543",
        displayName: "Jamie",
        avatarURL: nil,
        partnerID: "user123",
        coupleID: "couple789",
        currentMood: .great
    )
}
