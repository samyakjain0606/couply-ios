import SwiftUI

struct ConnectView: View {
    @EnvironmentObject var authService: AuthService
    @State private var selectedMood: Mood?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.couplyCream, Color.couplyLavenderMist.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 6) {
                            Text("Stay Connected")
                                .font(.custom("Fraunces", size: 26))
                                .foregroundColor(.couplyDarkWarm)

                            if let partner = authService.partner {
                                Text("Send some love to \(partner.displayName) 💕")
                                    .font(.system(size: 15))
                                    .foregroundColor(.couplyWarmGray)
                            }
                        }
                        .padding(.top, 10)

                        // Mood Ring
                        MoodRingCard(
                            selectedMood: $selectedMood,
                            partnerMood: authService.partner?.currentMood
                        )

                        // Digital Touch
                        DigitalTouchCard()

                        // Quick Actions Grid
                        QuickActionsGrid()

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            selectedMood = authService.currentUser?.currentMood
        }
        .onChange(of: selectedMood) { _, newMood in
            guard let mood = newMood else { return }
            Task {
                try? await authService.updateMood(mood)
            }
        }
    }
}

// MARK: - Mood Ring Card
struct MoodRingCard: View {
    @Binding var selectedMood: Mood?
    let partnerMood: Mood?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("How are you feeling?")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.couplyDarkWarm)

                Spacer()

                // Partner's mood
                if let mood = partnerMood {
                    HStack(spacing: 6) {
                        Text("Partner:")
                            .font(.system(size: 13))
                            .foregroundColor(.couplyWarmGray)
                        Text(mood.emoji)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.couplyPeachLight)
                    .clipShape(Capsule())
                }
            }

            // Mood grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    MoodOption(
                        mood: mood,
                        isSelected: selectedMood == mood
                    ) {
                        CouplyHaptics.selection()
                        withAnimation(.spring(response: 0.3)) {
                            selectedMood = mood
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.couplyCoral.opacity(0.1), radius: 10)
    }
}

struct MoodOption: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.system(size: 28))

                Text(mood.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .white : .couplyDarkWarm)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                isSelected
                    ? AnyShapeStyle(Color.couplyPrimaryGradient)
                    : AnyShapeStyle(Color.couplyPeachLight)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.couplyCoral : Color.couplyPeach, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? Color.couplyCoral.opacity(0.3) : .clear,
                radius: 8
            )
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Digital Touch Card
struct DigitalTouchCard: View {
    @State private var activeTouch: DigitalTouchType?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                Text("Digital Touch")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }

            HStack(spacing: 14) {
                ForEach(DigitalTouchType.allCases, id: \.self) { touch in
                    TouchButton(
                        type: touch,
                        isActive: activeTouch == touch
                    ) {
                        sendTouch(touch)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.couplyPrimaryGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.couplyHeartbeat.opacity(0.3), radius: 15)
    }

    private func sendTouch(_ type: DigitalTouchType) {
        activeTouch = type

        // Trigger haptic based on type
        switch type {
        case .heartbeat:
            CouplyHaptics.heartbeat()
        case .poke:
            CouplyHaptics.medium()
        case .hug:
            CouplyHaptics.heavy()
        }

        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            activeTouch = nil
        }

        // TODO: Send to partner via Firestore
    }
}

enum DigitalTouchType: String, CaseIterable {
    case heartbeat
    case poke
    case hug

    var icon: String {
        switch self {
        case .heartbeat: return "💓"
        case .poke: return "👆"
        case .hug: return "🤗"
        }
    }

    var label: String {
        switch self {
        case .heartbeat: return "Heartbeat"
        case .poke: return "Poke"
        case .hug: return "Hug"
        }
    }
}

struct TouchButton: View {
    let type: DigitalTouchType
    let isActive: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(type.icon)
                    .font(.system(size: 32))
                    .modifier(type == .heartbeat && !isActive ? HeartbeatModifier() : HeartbeatModifier())

                Text(type.label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white.opacity(isPressed ? 0.3 : 0.2))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Quick Actions Grid
struct QuickActionsGrid: View {
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 14) {
            QuickActionCard(
                icon: "⏰",
                title: "Countdown",
                gradient: [Color.couplyGoldenHour, Color(hex: "FFD700")]
            )

            QuickActionCard(
                icon: "📸",
                title: "Sync Moment",
                gradient: [Color(hex: "A78BFA"), Color(hex: "8B5CF6")]
            )

            QuickActionCard(
                icon: "🤪",
                title: "Ugly Wars",
                gradient: [Color(hex: "4ADE80"), Color(hex: "22C55E")]
            )

            QuickActionCard(
                icon: "✏️",
                title: "Doodle",
                gradient: [Color(hex: "60A5FA"), Color(hex: "3B82F6")]
            )
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let gradient: [Color]

    @State private var isPressed = false

    var body: some View {
        Button {
            CouplyHaptics.medium()
            // TODO: Navigate to feature
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)

                    Text(icon)
                        .font(.system(size: 22))
                }

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.couplyDarkWarm)

                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.couplyCoral.opacity(0.08), radius: 8)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isPressed = false
                    }
                }
        )
    }
}

#Preview {
    ConnectView()
        .environmentObject(AuthService.shared)
}
