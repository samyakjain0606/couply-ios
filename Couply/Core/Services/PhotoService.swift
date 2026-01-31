import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

@MainActor
class PhotoService: ObservableObject {
    static let shared = PhotoService()

    // MARK: - Published Properties
    @Published var photos: [Photo] = []
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0
    @Published var error: PhotoError?

    // MARK: - Private Properties
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var photosListener: ListenerRegistration?

    private init() {}

    // MARK: - Fetch Photos
    func startListening(for coupleID: String) {
        photosListener?.remove()
        photosListener = db.collection("photos")
            .whereField("coupleID", isEqualTo: coupleID)
            .order(by: "createdAt", descending: true)
            .limit(to: 100)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching photos: \(error)")
                    return
                }

                Task { @MainActor in
                    self.photos = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Photo.self)
                    } ?? []
                }
            }
    }

    func stopListening() {
        photosListener?.remove()
        photos = []
    }

    // MARK: - Upload Photo
    func uploadPhoto(
        image: UIImage,
        caption: String? = nil,
        isSyncMoment: Bool = false
    ) async throws -> Photo {
        guard let userID = AuthService.shared.currentUser?.id,
              let coupleID = AuthService.shared.currentUser?.coupleID else {
            throw PhotoError.notAuthenticated
        }

        isUploading = true
        uploadProgress = 0

        defer {
            Task { @MainActor in
                self.isUploading = false
                self.uploadProgress = 0
            }
        }

        // Compress image
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw PhotoError.compressionFailed
        }

        // Generate unique filename
        let photoID = UUID().uuidString
        let filename = "\(coupleID)/\(photoID).jpg"
        let storageRef = storage.reference().child("photos/\(filename)")

        // Upload image with progress tracking
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let uploadTask = storageRef.putData(imageData, metadata: metadata)

        // Track progress
        uploadTask.observe(.progress) { [weak self] snapshot in
            guard let progress = snapshot.progress else { return }
            Task { @MainActor in
                self?.uploadProgress = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            }
        }

        // Wait for upload to complete
        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<StorageMetadata, Error>) in
            uploadTask.observe(.success) { snapshot in
                continuation.resume(returning: snapshot.metadata!)
            }
            uploadTask.observe(.failure) { snapshot in
                continuation.resume(throwing: snapshot.error ?? PhotoError.uploadFailed)
            }
        }

        // Get download URL
        let downloadURL = try await storageRef.downloadURL()

        // Create thumbnail
        let thumbnailURL = try await uploadThumbnail(image: image, coupleID: coupleID, photoID: photoID)

        // Create photo document
        let photo = Photo(
            id: photoID,
            senderID: userID,
            coupleID: coupleID,
            imageURL: downloadURL.absoluteString,
            thumbnailURL: thumbnailURL,
            caption: caption,
            isSyncMoment: isSyncMoment
        )

        // Save to Firestore
        try await db.collection("photos").document(photoID).setData(photo.dictionary)

        // Update couple stats
        try await updateCoupleStats(coupleID: coupleID)

        // Send notification to partner
        await sendPhotoNotification()

        return photo
    }

    // MARK: - Upload Thumbnail
    private func uploadThumbnail(image: UIImage, coupleID: String, photoID: String) async throws -> String {
        // Create thumbnail (300px width)
        let thumbnailSize = CGSize(width: 300, height: 300 * image.size.height / image.size.width)
        let thumbnail = image.preparingThumbnail(of: thumbnailSize) ?? image

        guard let thumbnailData = thumbnail.jpegData(compressionQuality: 0.5) else {
            throw PhotoError.compressionFailed
        }

        let filename = "\(coupleID)/thumbnails/\(photoID)_thumb.jpg"
        let storageRef = storage.reference().child("photos/\(filename)")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await storageRef.putDataAsync(thumbnailData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()

        return downloadURL.absoluteString
    }

    // MARK: - Update Couple Stats
    private func updateCoupleStats(coupleID: String) async throws {
        let coupleRef = db.collection("couples").document(coupleID)

        try await db.runTransaction { transaction, errorPointer in
            let coupleDoc: DocumentSnapshot
            do {
                coupleDoc = try transaction.getDocument(coupleRef)
            } catch let error {
                errorPointer?.pointee = error as NSError
                return nil
            }

            guard var data = coupleDoc.data() else {
                return nil
            }

            let currentStreak = data["streakCount"] as? Int ?? 0
            let longestStreak = data["longestStreak"] as? Int ?? 0
            let totalPhotos = data["totalPhotosExchanged"] as? Int ?? 0

            // Check if streak should increase
            var newStreak = currentStreak
            if let lastUpdate = (data["lastStreakUpdate"] as? Timestamp)?.dateValue() {
                let calendar = Calendar.current
                if !calendar.isDateInToday(lastUpdate) {
                    // New day, increment streak
                    newStreak = currentStreak + 1
                }
            } else {
                // First photo ever
                newStreak = 1
            }

            transaction.updateData([
                "streakCount": newStreak,
                "longestStreak": max(longestStreak, newStreak),
                "totalPhotosExchanged": totalPhotos + 1,
                "lastPhotoDate": Timestamp(date: Date()),
                "lastStreakUpdate": Timestamp(date: Date())
            ], forDocument: coupleRef)

            return nil
        }
    }

    // MARK: - Send Notification
    private func sendPhotoNotification() async {
        guard let partner = AuthService.shared.partner,
              let fcmToken = partner.fcmToken,
              let senderName = AuthService.shared.currentUser?.displayName else {
            return
        }

        // This would typically call a Cloud Function to send the notification
        // For now, we'll just log it
        print("Would send notification to \(fcmToken): New photo from \(senderName)")
    }

    // MARK: - React to Photo
    func reactToPhoto(_ photoID: String, reaction: PhotoReaction) async throws {
        try await db.collection("photos").document(photoID).updateData([
            "reaction": reaction.rawValue
        ])
        CouplyHaptics.success()
    }

    // MARK: - Mark Photo as Viewed
    func markAsViewed(_ photoID: String) async throws {
        try await db.collection("photos").document(photoID).updateData([
            "viewedAt": Timestamp(date: Date())
        ])
    }

    // MARK: - Delete Photo
    func deletePhoto(_ photo: Photo) async throws {
        guard let photoID = photo.id else { return }

        // Delete from Storage
        let storageRef = storage.reference().child("photos/\(photo.coupleID)/\(photoID).jpg")
        try await storageRef.delete()

        // Delete thumbnail
        let thumbRef = storage.reference().child("photos/\(photo.coupleID)/thumbnails/\(photoID)_thumb.jpg")
        try? await thumbRef.delete()

        // Delete from Firestore
        try await db.collection("photos").document(photoID).delete()
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
