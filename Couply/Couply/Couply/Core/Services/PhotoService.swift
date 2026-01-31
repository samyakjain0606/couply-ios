import Foundation
import Combine
import UIKit

@MainActor
class PhotoService: ObservableObject {
    static let shared = PhotoService()

    // MARK: - Published Properties
    @Published var photos: [Photo] = []
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0
    @Published var error: PhotoError?

    private init() {
        // Load demo photos
        loadDemoPhotos()
    }

    // MARK: - Demo Photos
    private func loadDemoPhotos() {
        photos = [
            Photo(
                id: "photo-1",
                senderID: "demo-partner-456",
                coupleID: "demo-couple-789",
                imageURL: "https://picsum.photos/400/500?random=1",
                thumbnailURL: "https://picsum.photos/200/250?random=1",
                caption: "Missing you! 💕",
                reaction: .heart,
                createdAt: Date().addingTimeInterval(-3600)
            ),
            Photo(
                id: "photo-2",
                senderID: "demo-user-123",
                coupleID: "demo-couple-789",
                imageURL: "https://picsum.photos/400/500?random=2",
                thumbnailURL: "https://picsum.photos/200/250?random=2",
                caption: "Good morning!",
                createdAt: Date().addingTimeInterval(-7200)
            ),
            Photo(
                id: "photo-3",
                senderID: "demo-partner-456",
                coupleID: "demo-couple-789",
                imageURL: "https://picsum.photos/400/500?random=3",
                thumbnailURL: "https://picsum.photos/200/250?random=3",
                isSyncMoment: true,
                createdAt: Date().addingTimeInterval(-86400)
            ),
            Photo(
                id: "photo-4",
                senderID: "demo-user-123",
                coupleID: "demo-couple-789",
                imageURL: "https://picsum.photos/400/500?random=4",
                thumbnailURL: "https://picsum.photos/200/250?random=4",
                caption: "Date night! 🍝",
                reaction: .fire,
                createdAt: Date().addingTimeInterval(-172800)
            ),
            Photo(
                id: "photo-5",
                senderID: "demo-partner-456",
                coupleID: "demo-couple-789",
                imageURL: "https://picsum.photos/400/500?random=5",
                thumbnailURL: "https://picsum.photos/200/250?random=5",
                reaction: .love,
                createdAt: Date().addingTimeInterval(-259200)
            )
        ]
    }

    // MARK: - Fetch Photos
    func startListening(for coupleID: String) {
        // Already loaded demo photos
    }

    func stopListening() {
        // No-op in demo mode
    }

    // MARK: - Upload Photo
    func uploadPhoto(
        image: UIImage,
        caption: String? = nil,
        isSyncMoment: Bool = false
    ) async throws -> Photo {
        isUploading = true
        uploadProgress = 0

        // Simulate upload progress
        for i in 1...10 {
            try await Task.sleep(nanoseconds: 100_000_000)
            uploadProgress = Double(i) / 10.0
        }

        let photo = Photo(
            id: UUID().uuidString,
            senderID: AuthService.shared.currentUser?.id ?? "",
            coupleID: AuthService.shared.currentUser?.coupleID ?? "",
            imageURL: "https://picsum.photos/400/500?random=\(Int.random(in: 100...999))",
            thumbnailURL: "https://picsum.photos/200/250?random=\(Int.random(in: 100...999))",
            caption: caption,
            isSyncMoment: isSyncMoment
        )

        photos.insert(photo, at: 0)

        isUploading = false
        uploadProgress = 0

        return photo
    }

    // MARK: - React to Photo
    func reactToPhoto(_ photoID: String, reaction: PhotoReaction) async throws {
        if let index = photos.firstIndex(where: { $0.id == photoID }) {
            photos[index].reaction = reaction
        }
        CouplyHaptics.success()
    }

    // MARK: - Mark Photo as Viewed
    func markAsViewed(_ photoID: String) async throws {
        if let index = photos.firstIndex(where: { $0.id == photoID }) {
            photos[index].viewedAt = Date()
        }
    }

    // MARK: - Delete Photo
    func deletePhoto(_ photo: Photo) async throws {
        photos.removeAll { $0.id == photo.id }
    }

    // MARK: - Filter Photos
    func filteredPhotos(by filter: PhotoFilter, userID: String) -> [Photo] {
        switch filter {
        case .all:
            return photos
        case .sent:
            return photos.filter { $0.senderID == userID }
        case .received:
            return photos.filter { $0.senderID != userID }
        case .favorites:
            return photos.filter { $0.reaction != nil }
        }
    }
}

// MARK: - Photo Errors
enum PhotoError: LocalizedError {
    case notAuthenticated
    case compressionFailed
    case uploadFailed
    case downloadFailed
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to share photos."
        case .compressionFailed:
            return "Failed to process the image."
        case .uploadFailed:
            return "Failed to upload the photo. Please try again."
        case .downloadFailed:
            return "Failed to load the photo."
        case .deleteFailed:
            return "Failed to delete the photo."
        }
    }
}
