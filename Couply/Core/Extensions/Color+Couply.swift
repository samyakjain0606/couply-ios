import SwiftUI

extension Color {
    // MARK: - Primary Colors
    static let couplyPeachLight = Color(hex: "FFF5F0")
    static let couplyPeach = Color(hex: "FFDDD2")
    static let couplyCoral = Color(hex: "FF8A7A")
    static let couplyCoralDeep = Color(hex: "E76F5A")
    static let couplyRose = Color(hex: "FFB4A2")
    static let couplyRoseDeep = Color(hex: "E5989B")
    static let couplyBlush = Color(hex: "FFCDB2")
    static let couplyCream = Color(hex: "FFF8F5")
    static let couplyWarmWhite = Color(hex: "FFFAF8")

    // MARK: - Neutral Colors
    static let couplySoftBrown = Color(hex: "6D5D4E")
    static let couplyWarmGray = Color(hex: "8B7E74")
    static let couplyDarkWarm = Color(hex: "3D3228")

    // MARK: - Accent Colors
    static let couplyLoveRed = Color(hex: "FF6B6B")
    static let couplyHeartbeat = Color(hex: "FF4D6D")
    static let couplyGoldenHour = Color(hex: "FFB347")
    static let couplyLavenderMist = Color(hex: "E8D5E0")

    // MARK: - Functional Colors
    static let couplySuccess = Color(hex: "4ADE80")
    static let couplyWarning = Color(hex: "FBBF24")
    static let couplyError = Color(hex: "EF4444")

    // MARK: - Gradients
    static var couplyPrimaryGradient: LinearGradient {
        LinearGradient(
            colors: [couplyCoral, couplyHeartbeat],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var couplySecondaryGradient: LinearGradient {
        LinearGradient(
            colors: [couplyRose, couplyRoseDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var couplyBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [couplyCream, couplyPeachLight],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var couplyWarmGradient: LinearGradient {
        LinearGradient(
            colors: [couplyPeach, couplyRose, couplyCoral],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - ShapeStyle Extension for Gradients
extension ShapeStyle where Self == LinearGradient {
    static var couplyPrimary: LinearGradient { Color.couplyPrimaryGradient }
    static var couplySecondary: LinearGradient { Color.couplySecondaryGradient }
    static var couplyBackground: LinearGradient { Color.couplyBackgroundGradient }
}
