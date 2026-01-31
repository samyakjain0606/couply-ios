import SwiftUI

// MARK: - View Modifiers
extension View {

    /// Apply Couply card styling
    func couplyCard(padding: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.couplyCoral.opacity(0.15), radius: 10, x: 0, y: 4)
    }

    /// Apply soft shadow
    func couplyShadow(radius: CGFloat = 10) -> some View {
        self.shadow(color: Color.couplyCoral.opacity(0.2), radius: radius, x: 0, y: 4)
    }

    /// Apply glow effect
    func couplyGlow(color: Color = .couplyCoral, radius: CGFloat = 20) -> some View {
        self.shadow(color: color.opacity(0.4), radius: radius, x: 0, y: 0)
    }

    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Breathing animation
    func breathingAnimation(duration: Double = 3.0) -> some View {
        self.modifier(BreathingModifier(duration: duration))
    }

    /// Heartbeat animation
    func heartbeatAnimation() -> some View {
        self.modifier(HeartbeatModifier())
    }
}

// MARK: - Custom Modifiers
struct BreathingModifier: ViewModifier {
    let duration: Double
    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.05
                }
            }
    }
}

struct HeartbeatModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                let animation = Animation
                    .easeInOut(duration: 0.15)
                    .repeatForever(autoreverses: true)

                withAnimation(animation.delay(0)) {
                    scale = 1.15
                }
            }
    }
}

// MARK: - Custom Button Styles
struct CouplyPrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                Group {
                    if isDisabled {
                        Color.couplyWarmGray.opacity(0.5)
                    } else {
                        Color.couplyPrimaryGradient
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .shadow(
                color: isDisabled ? .clear : Color.couplyHeartbeat.opacity(0.3),
                radius: configuration.isPressed ? 5 : 10,
                x: 0,
                y: configuration.isPressed ? 2 : 5
            )
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct CouplySecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.couplyCoralDeep)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.couplyPeachLight)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.couplyPeach, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct CouplyIconButtonStyle: ButtonStyle {
    var size: CGFloat = 44
    var backgroundColor: Color = Color.white.opacity(0.15)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(backgroundColor)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions
extension ButtonStyle where Self == CouplyPrimaryButtonStyle {
    static var couplyPrimary: CouplyPrimaryButtonStyle { CouplyPrimaryButtonStyle() }
    static func couplyPrimary(disabled: Bool) -> CouplyPrimaryButtonStyle {
        CouplyPrimaryButtonStyle(isDisabled: disabled)
    }
}

extension ButtonStyle where Self == CouplySecondaryButtonStyle {
    static var couplySecondary: CouplySecondaryButtonStyle { CouplySecondaryButtonStyle() }
}

// MARK: - Custom Text Field Style
struct CouplyTextFieldStyle: TextFieldStyle {
    var icon: String?

    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.couplyWarmGray)
                    .frame(width: 20)
            }

            configuration
                .font(.system(size: 16))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.couplyPeachLight)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.couplyPeach, lineWidth: 2)
        )
    }
}

// MARK: - Haptic Feedback
enum CouplyHaptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func heartbeat() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            generator.impactOccurred(intensity: 0.7)
        }
    }
}
