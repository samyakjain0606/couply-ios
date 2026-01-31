import Foundation
import FirebaseFirestore

struct Couple: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let user1ID: String
    let user2ID: String
    var inviteCode: String?
    var streakCount: Int
    var longestStreak: Int
    var lastPhotoDate: Date?
    var lastStreakUpdate: Date?
    var totalPhotosExchanged: Int
    var anniversaryDate: Date?
    let createdAt: Date

    // MARK: - Computed Properties
    var isStreakActive: Bool {
        guard let lastPhoto = lastPhotoDate else { return false }
        let calendar = Calendar.current
        return calendar.isDateInToday(lastPhoto) || calendar.isDateInYesterday(lastPhoto)
    }

    var streakExpiresIn: TimeInterval? {
        guard let lastUpdate = lastStreakUpdate else { return nil }
        let calendar = Calendar.current

        // Streak expires at end of next day after last update
        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: lastUpdate),
              let expirationDate = calendar.date(byAdding: .day, value: 1, to: endOfDay) else {
            return nil
        }

        let remaining = expirationDate.timeIntervalSince(Date())
        return remaining > 0 ? remaining : nil
    }

    var daysConnected: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: createdAt, to: Date())
        return components.day ?? 0
    }

    // MARK: - Initializer
    init(
        id: String? = nil,
        user1ID: String,
        user2ID: String,
        inviteCode: String? = nil,
        streakCount: Int = 0,
        longestStreak: Int = 0,
        lastPhotoDate: Date? = nil,
        lastStreakUpdate: Date? = nil,
        totalPhotosExchanged: Int = 0,
        anniversaryDate: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.user1ID = user1ID
        self.user2ID = user2ID
        self.inviteCode = inviteCode
        self.streakCount = streakCount
        self.longestStreak = longestStreak
        self.lastPhotoDate = lastPhotoDate
        self.lastStreakUpdate = lastStreakUpdate
        self.totalPhotosExchanged = totalPhotosExchanged
        self.anniversaryDate = anniversaryDate
        self.createdAt = createdAt
    }

    // MARK: - Firestore Dictionary
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "user1ID": user1ID,
            "user2ID": user2ID,
            "streakCount": streakCount,
            "longestStreak": longestStreak,
            "totalPhotosExchanged": totalPhotosExchanged,
            "createdAt": Timestamp(date: createdAt)
        ]

        if let inviteCode = inviteCode { dict["inviteCode"] = inviteCode }
        if let lastPhotoDate = lastPhotoDate { dict["lastPhotoDate"] = Timestamp(date: lastPhotoDate) }
        if let lastStreakUpdate = lastStreakUpdate { dict["lastStreakUpdate"] = Timestamp(date: lastStreakUpdate) }
        if let anniversaryDate = anniversaryDate { dict["anniversaryDate"] = Timestamp(date: anniversaryDate) }

        return dict
    }

    // MARK: - Helper Methods
    func partnerID(for userID: String) -> String {
        userID == user1ID ? user2ID : user1ID
    }
}

// MARK: - Invite Code
struct InviteCode: Codable {
    let code: String
    let creatorID: String
    let createdAt: Date
    var usedBy: String?
    var usedAt: Date?
    let expiresAt: Date

    var isExpired: Bool {
        Date() > expiresAt
    }

    var isUsed: Bool {
        usedBy != nil
    }

    var isValid: Bool {
        !isExpired && !isUsed
    }

    static func generate(for userID: String) -> InviteCode {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        let randomPart = String((0..<4).map { _ in characters.randomElement()! })
        let code = "LOVE-\(randomPart)"

        return InviteCode(
            code: code,
            creatorID: userID,
            createdAt: Date(),
            expiresAt: Calendar.current.date(byAdding: .hour, value: 24, to: Date())!
        )
    }
}

// MARK: - Streak Milestone
enum StreakMilestone: Int, CaseIterable {
    case week = 7
    case month = 30
    case quarter = 100
    case year = 365

    var emoji: String {
        switch self {
        case .week: return "🔥"
        case .month: return "⭐"
        case .quarter: return "💎"
        case .year: return "👑"
        }
    }

    var title: String {
        switch self {
        case .week: return "1 Week!"
        case .month: return "1 Month!"
        case .quarter: return "100 Days!"
        case .year: return "1 Year!"
        }
    }

    var message: String {
        switch self {
        case .week: return "Amazing! You've kept the streak for a week!"
        case .month: return "Incredible! A whole month of sharing moments!"
        case .quarter: return "Legendary! 100 days of connection!"
        case .year: return "Extraordinary! A full year of love!"
        }
    }

    static func milestone(for count: Int) -> StreakMilestone? {
        allCases.first { count == $0.rawValue }
    }
}

// MARK: - Sample Data
extension Couple {
    static let sample = Couple(
        id: "couple789",
        user1ID: "user123",
        user2ID: "partner456",
        streakCount: 47,
        longestStreak: 52,
        lastPhotoDate: Date(),
        totalPhotosExchanged: 234,
        anniversaryDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())
    )
}
