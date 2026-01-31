import SwiftUI
import Kingfisher

struct FeedView: View {
    @StateObject private var photoService = PhotoService.shared
    @EnvironmentObject var authService: AuthService
    @State private var selectedFilter: PhotoFilter = .all
    @State private var selectedPhoto: Photo?

    var filteredPhotos: [Photo] {
        guard let userID = authService.currentUser?.id else { return [] }
        return photoService.filteredPhotos(by: selectedFilter, userID: userID)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.couplyWarmWhite.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Filter pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(PhotoFilter.allCases, id: \.self) { filter in
                                FilterPill(
                                    filter: filter,
                                    isSelected: selectedFilter == filter
                                ) {
                                    CouplyHaptics.selection()
                                    withAnimation {
                                        selectedFilter = filter
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 12)
                    .background(Color.couplyCream)

                    // Photo grid
                    if filteredPhotos.isEmpty {
                        EmptyFeedView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredPhotos) { photo in
                                    PhotoCard(photo: photo, currentUserID: authService.currentUser?.id ?? "") {
                                        selectedPhoto = photo
                                    }
                                }
                            }
                            .padding(16)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationTitle("Memories")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedPhoto) { photo in
                PhotoDetailView(photo: photo)
            }
        }
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let filter: PhotoFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if filter == .favorites {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                } else {
                    Text(filter.rawValue)
                }
            }
            .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
            .foregroundColor(isSelected ? .white : .couplyWarmGray)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? AnyShapeStyle(Color.couplyPrimaryGradient)
                    : AnyShapeStyle(Color.couplyPeachLight)
            )
            .clipShape(Capsule())
            .shadow(
                color: isSelected ? Color.couplyCoral.opacity(0.3) : .clear,
                radius: 5, y: 2
            )
        }
    }
}

// MARK: - Photo Card
struct PhotoCard: View {
    let photo: Photo
    let currentUserID: String
    let onTap: () -> Void

    @State private var isVisible = false

    var isSent: Bool {
        photo.senderID == currentUserID
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Photo
                ZStack(alignment: .topTrailing) {
                    // Placeholder gradient (shown while loading)
                    Rectangle()
                        .fill(Color.couplyWarmGradient)
                        .aspectRatio(4/5, contentMode: .fit)

                    // Actual image
                    if let url = URL(string: photo.thumbnailURL ?? photo.imageURL) {
                        KFImage(url)
                            .placeholder {
                                Rectangle()
                                    .fill(Color.couplyPeach)
                            }
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(4/5, contentMode: .fit)
                            .clipped()
                    }

                    // Time badge
                    Text(photo.timeAgo)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Capsule())
                        .padding(12)

                    // Unviewed indicator
                    if !photo.isViewed && !isSent {
                        Circle()
                            .fill(Color.couplyCoral)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .position(x: 20, y: 20)
                    }

                    // Sync moment badge
                    if photo.isSyncMoment {
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                            Text("Sync")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.8))
                        .clipShape(Capsule())
                        .position(x: 45, y: 20)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                // Footer
                HStack {
                    // Sender info
                    HStack(spacing: 8) {
                        Circle()
                            .fill(isSent ? Color(hex: "A78BFA") : Color.couplyPrimaryGradient)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(isSent ? "😊" : "🥰")
                                    .font(.system(size: 16))
                            )

                        Text(isSent ? "You" : "Partner")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.couplyDarkWarm)
                    }

                    Spacer()

                    // Reactions
                    HStack(spacing: 8) {
                        ReactionButton(
                            reaction: .heart,
                            isSelected: photo.reaction == .heart,
                            photoID: photo.id ?? ""
                        )

                        ReactionButton(
                            reaction: .fire,
                            isSelected: photo.reaction == .fire,
                            photoID: photo.id ?? ""
                        )

                        ReactionButton(
                            reaction: .love,
                            isSelected: photo.reaction == .love,
                            photoID: photo.id ?? ""
                        )
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 12)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 30)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Reaction Button
struct ReactionButton: View {
    let reaction: PhotoReaction
    let isSelected: Bool
    let photoID: String

    var body: some View {
        Button {
            CouplyHaptics.light()
            Task {
                try? await PhotoService.shared.reactToPhoto(photoID, reaction: reaction)
            }
        } label: {
            Text(reaction.emoji)
                .font(.system(size: 18))
                .padding(8)
                .background(
                    isSelected
                        ? Color.couplyPeach
                        : Color.couplyPeachLight
                )
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.couplyCoral : Color.couplyPeach, lineWidth: 1.5)
                )
                .scaleEffect(isSelected ? 1.1 : 1.0)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Empty Feed View
struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.couplyPeachLight)
                    .frame(width: 120, height: 120)

                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 50))
                    .foregroundColor(.couplyPeach)
            }

            VStack(spacing: 8) {
                Text("No photos yet")
                    .font(.custom("Fraunces", size: 22))
                    .foregroundColor(.couplyDarkWarm)

                Text("Send your first photo to get started!")
                    .font(.system(size: 15))
                    .foregroundColor(.couplyWarmGray)
            }

            Spacer()
        }
    }
}

// MARK: - Photo Detail View
struct PhotoDetailView: View {
    let photo: Photo
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReaction: PhotoReaction?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                // Photo
                if let url = URL(string: photo.imageURL) {
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                }

                // Caption overlay
                if let caption = photo.caption {
                    VStack {
                        Spacer()

                        Text(caption)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Capsule())
                            .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Text(photo.formattedDate)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onAppear {
            // Mark as viewed
            if let photoID = photo.id, photo.viewedAt == nil {
                Task {
                    try? await PhotoService.shared.markAsViewed(photoID)
                }
            }
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(AuthService.shared)
}
