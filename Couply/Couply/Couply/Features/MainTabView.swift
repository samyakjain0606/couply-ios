import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .camera
    @EnvironmentObject var authService: AuthService
    @StateObject private var photoService = PhotoService.shared

    enum Tab: Int, CaseIterable {
        case chat
        case feed
        case camera
        case connect
        case profile

        var icon: String {
            switch self {
            case .chat: return "bubble.left.fill"
            case .feed: return "house.fill"
            case .camera: return "camera.fill"
            case .connect: return "heart.fill"
            case .profile: return "person.fill"
            }
        }

        var label: String {
            switch self {
            case .chat: return "Chat"
            case .feed: return "Feed"
            case .camera: return "Camera"
            case .connect: return "Connect"
            case .profile: return "Profile"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            TabView(selection: $selectedTab) {
                ChatView()
                    .tag(Tab.chat)

                FeedView()
                    .tag(Tab.feed)

                CameraView()
                    .tag(Tab.camera)

                ConnectView()
                    .tag(Tab.connect)

                ProfileView()
                    .tag(Tab.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            if let coupleID = authService.currentUser?.coupleID {
                photoService.startListening(for: coupleID)
            }
        }
        .onDisappear {
            photoService.stopListening()
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTabView.Tab.allCases, id: \.rawValue) { tab in
                if tab == .camera {
                    // Center camera button (elevated)
                    CameraTabButton(isSelected: selectedTab == tab) {
                        CouplyHaptics.medium()
                        selectedTab = tab
                    }
                } else {
                    TabBarButton(
                        tab: tab,
                        isSelected: selectedTab == tab
                    ) {
                        CouplyHaptics.selection()
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.8))
                )
                .shadow(color: Color.black.opacity(0.05), radius: 20, y: -5)
        )
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: MainTabView.Tab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .couplyCoralDeep : .couplyWarmGray.opacity(0.6))

                Text(tab.label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .couplyCoralDeep : .couplyWarmGray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Camera Tab Button
struct CameraTabButton: View {
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.couplyPrimaryGradient)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.couplyHeartbeat.opacity(0.4), radius: 10, y: 4)

                Image(systemName: "camera.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            .offset(y: -12)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Placeholder Views (to be replaced)
struct ChatView: View {
    var body: some View {
        ZStack {
            Color.couplyWarmWhite.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 60))
                    .foregroundColor(.couplyPeach)

                Text("Chat")
                    .font(.custom("Fraunces", size: 24))
                    .foregroundColor(.couplyDarkWarm)

                Text("Coming soon...")
                    .font(.system(size: 15))
                    .foregroundColor(.couplyWarmGray)
            }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        NavigationStack {
            ZStack {
                Color.couplyWarmWhite.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Profile header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.couplyPrimaryGradient)
                                .frame(width: 100, height: 100)

                            Text("😊")
                                .font(.system(size: 45))
                        }
                        .shadow(color: Color.couplyCoral.opacity(0.3), radius: 10)

                        VStack(spacing: 4) {
                            Text(authService.currentUser?.displayName ?? "You")
                                .font(.custom("Fraunces", size: 24))
                                .foregroundColor(.couplyDarkWarm)

                            if let mood = authService.currentUser?.currentMood {
                                HStack(spacing: 4) {
                                    Text(mood.emoji)
                                    Text(mood.message)
                                        .font(.system(size: 14))
                                        .foregroundColor(.couplyWarmGray)
                                }
                            }
                        }
                    }
                    .padding(.top, 40)

                    // Streak card
                    if let couple = authService.couple {
                        HStack(spacing: 20) {
                            VStack {
                                Text("🔥")
                                    .font(.system(size: 28))
                                Text("\(couple.streakCount)")
                                    .font(.custom("Fraunces", size: 24))
                                    .foregroundColor(.couplyDarkWarm)
                                Text("Streak")
                                    .font(.system(size: 12))
                                    .foregroundColor(.couplyWarmGray)
                            }

                            Divider()
                                .frame(height: 50)

                            VStack {
                                Text("📸")
                                    .font(.system(size: 28))
                                Text("\(couple.totalPhotosExchanged)")
                                    .font(.custom("Fraunces", size: 24))
                                    .foregroundColor(.couplyDarkWarm)
                                Text("Photos")
                                    .font(.system(size: 12))
                                    .foregroundColor(.couplyWarmGray)
                            }

                            Divider()
                                .frame(height: 50)

                            VStack {
                                Text("💕")
                                    .font(.system(size: 28))
                                Text("\(couple.daysConnected)")
                                    .font(.custom("Fraunces", size: 24))
                                    .foregroundColor(.couplyDarkWarm)
                                Text("Days")
                                    .font(.system(size: 12))
                                    .foregroundColor(.couplyWarmGray)
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.couplyCoral.opacity(0.1), radius: 10)
                        .padding(.horizontal, 24)
                    }

                    Spacer()

                    // Sign out button
                    Button {
                        try? authService.signOut()
                    } label: {
                        Text("Sign Out")
                            .foregroundColor(.couplyError)
                    }
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthService.shared)
}
