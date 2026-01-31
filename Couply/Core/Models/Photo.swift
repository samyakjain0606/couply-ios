import Foundation
import FirebaseFirestore

struct Photo: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let senderID: String
    let coupleID: String
    let imageURL: String
    var thumbnailURL: String?
    var caption: String?
    var reaction: PhotoReaction?
    var viewedAt: Date?
    var isSyncMoment: Bool
    var syncMomentPairID: String?
    let createdAt: Date

    // MARK: - Computed Properties
    var isViewed: Bool {
        viewedAt != nil
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    // MARK: - Initializer
    init(
        id: String? = nil,
        senderID: String,
        coupleID: String,
        imageURL: String,
        thumbnailURL: String? = nil,
        caption: String? = nil,
        reaction: PhotoReaction? = nil,
        viewedAt: Date? = nil,
        isSyncMoment: Bool = false,
        syncMomentPairID: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.senderID = senderID
        self.coupleID = coupleID
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
        self.caption = caption
        self.reaction = reaction
        self.viewedAt = viewedAt
        self.isSyncMoment = isSyncMoment
        self.syncMomentPairID = syncMomentPairID
        self.createdAt = createdAt
    }

    // MARK: - Firestore Dictionary
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "senderID": senderID,
            "coupleID": coupleID,
            "imageURL": imageURL,
            "isSyncMoment": isSyncMoment,
            "createdAt": Timestamp(date: createdAt)
        ]

        if let thumbnailURL = thumbnailURL { dict["thumbnailURL"] = thumbnailURL }
        if let caption = caption { dict["caption"] = caption }
        if let reaction = reaction { dict["reaction"] = reaction.rawValue }
        if let viewedAt = viewedAt { dict["viewedAt"] = Timestamp(date: viewedAt) }
        if let syncMomentPairID = syncMomentPairID { dict["syncMomentPairID"] = syncMomentPairID }

        return dict
    }

    // MARK: - Helpers
    func isSentBy(_ userID: String) -> Bool {
        senderID == userID
    }
}

// MARK: - Photo Reaction
enum PhotoReaction: String, Codable, CaseIterable {
    case heart = "heart"
    case fire = "fire"
    case laugh = "laugh"
    case love = "love"
    case kiss = "kiss"
    case hug = "hug"

    var emoji: String {
        switch self {
        case .heart: return "❤️"
        case .fire: return "🔥"
        case .laugh: return "😂"
        case .love: return "😍"
        case .kiss: return "💋"
        case .hug: return "🤗"
        }
    }
}

// MARK: - Photo Filter
enum PhotoFilter: String, CaseIterable {
    case all = "All"
    case sent = "Sent"
    case received = "Received"
    case favorites = "Favorites"

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .sent: return "arrow.up.circle"
        case .received: return "arrow.down.circle"
        case .favorites: return "heart.fill"
        }
    }
}

// MARK: - Sync Moment
struct SyncMoment: Identifiable, Codable {
    @DocumentID var id: String?
    let coupleID: String
    let initiatorID: String
    var user1PhotoID: String?
    var user2PhotoID: String?
    var user1CompletedAt: Date?
    var user2CompletedAt: Date?
    let expiresAt: Date
    let createdAt: Date

    var isComplete: Bool {
        user1PhotoID != nil && user2PhotoID != nil
    }

    var isExpired: Bool {
        Date() > expiresAt
    }

    static func create(coupleID: String, initiatorID: String) -> SyncMoment {
        SyncMoment(
            coupleID: coupleID,
            initiatorID: initiatorID,
            expiresAt: Calendar.current.date(byAdding: .minute, value: 5, to: Date())!,
            createdAt: Date()
        )
    }
}

// MARK: - Sample Data
extension Photo {
    static let samples: [Photo] = [
        Photo(
            id: "photo1",
            senderID: "partner456",
            coupleID: "couple789",
            imageURL: "https://example.com/photo1.jpg",
            caption: "Good morning! ☀️",
            reaction: .heart,
            viewedAt: Date(),
            createdAt: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        ),
        Photo(
            id: "photo2",
            senderID: "user123",
            coupleID: "couple789",
            imageURL: "https://example.com/photo2.jpg",
            caption: "Coffee time ☕",
            createdAt: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!
        ),
        Photo(
            id: "photo3",
            senderID: "partner456",
            coupleID: "couple789",
            imageURL: "https://example.com/photo3.jpg",
            reaction: .fire,
            viewedAt: Date(),
            isSyncMoment: true,
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        )
    ]
}
