import SwiftUI

struct OnboardingView: View {
    @State private var showPhoneAuth = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.couplyCream,
                        Color.couplyPeachLight,
                        Color.couplyRose.opacity(0.6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Floating hearts background
                FloatingHeartsView()

                VStack(spacing: 0) {
                    Spacer()

                    // Logo
                    VStack(spacing: 24) {
                        ZStack {
                            // Glow effect
                            Circle()
                                .fill(Color.couplyCoral.opacity(0.3))
                                .frame(width: 140, height: 140)
                                .blur(radius: 20)

                            // Logo container
                            ZStack {
                                Circle()
                                    .fill(Color.couplyPrimaryGradient)
                                    .frame(width: 120, height: 120)

                                Text("💕")
                                    .font(.system(size: 55))
                            }
                            .shadow(color: Color.couplyCoral.opacity(0.4), radius: 20, x: 0, y: 10)
                            .breathingAnimation(duration: 3.0)
                        }

                        VStack(spacing: 8) {
                            Text("Couply")
                                .font(.custom("Fraunces", size: 42))
                                .fontWeight(.semibold)
                                .foregroundColor(.couplyDarkWarm)

                            Text("Feel connected in 2 seconds")
                                .font(.system(size: 17))
                                .foregroundColor(.couplyWarmGray)
                        }
                    }

                    Spacer()

                    // Hearts animation
                    HStack(spacing: 20) {
                        ForEach(0..<3) { index in
                            Text(["💗", "💖", "💝"][index])
                                .font(.system(size: 28))
                                .modifier(HeartBounceModifier(delay: Double(index) * 0.2))
                        }
                    }
                    .padding(.bottom, 50)

                    // CTA Buttons
                    VStack(spacing: 16) {
                        Button {
                            CouplyHaptics.medium()
                            showPhoneAuth = true
                        } label: {
                            Text("Get Started")
                        }
                        .buttonStyle(.couplyPrimary)

                        Button {
                            CouplyHaptics.light()
                            showPhoneAuth = true
                        } label: {
                            HStack(spacing: 4) {
                                Text("Already have an account?")
                                    .foregroundColor(.couplyWarmGray)
                                Text("Sign in")
                                    .foregroundColor(.couplyCoralDeep)
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 15))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)

                    // Progress indicator
                    ProgressDotsView(currentStep: 0, totalSteps: 4)
                        .padding(.bottom, 20)
                }
            }
            .navigationDestination(isPresented: $showPhoneAuth) {
                PhoneAuthView()
            }
        }
    }
}

// MARK: - Floating Hearts Background
struct FloatingHeartsView: View {
    let hearts = ["💕", "💗", "💖", "💝", "❤️", "🩷"]

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<8, id: \.self) { index in
                Text(hearts[index % hearts.count])
                    .font(.system(size: CGFloat.random(in: 16...28)))
                    .opacity(0.15)
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
                    .modifier(FloatingModifier(delay: Double(index) * 0.5))
            }
        }
    }
}

// MARK: - Heart Bounce Modifier
struct HeartBounceModifier: ViewModifier {
    let delay: Double
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .animation(
                Animation
                    .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Floating Modifier
struct FloatingModifier: ViewModifier {
    let delay: Double
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .animation(
                Animation
                    .easeInOut(duration: Double.random(in: 3...5))
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: offset
            )
            .onAppear {
                offset = CGFloat.random(in: -20...20)
            }
    }
}

// MARK: - Progress Dots
struct ProgressDotsView: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? Color.couplyCoral : Color.couplyPeach)
                    .frame(width: index == currentStep ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
