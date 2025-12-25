import SwiftUI
import Combine

enum CavePalette {

    static let background = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.04, blue: 0.06),
            Color(red: 0.10, green: 0.07, blue: 0.09)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let depthGlow = RadialGradient(
        colors: [
            Color(red: 1.00, green: 0.72, blue: 0.28).opacity(0.25),
            Color.clear
        ],
        center: .center,
        startRadius: 20,
        endRadius: 420
    )

    static let accent = Color(red: 1.00, green: 0.72, blue: 0.28)
    static let accentSoft = accent.opacity(0.45)
    static let glow = accentSoft
    static let ember = Color(red: 1.00, green: 0.56, blue: 0.22)

    static let surface = Color(red: 0.14, green: 0.12, blue: 0.16)
    static let surfaceStrong = Color(red: 0.18, green: 0.15, blue: 0.20)
    static let panel = surfaceStrong

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.65)

    static let borderSoft = Color.white.opacity(0.10)
    static let border = borderSoft
    static let mist = Color.white.opacity(0.06)

    static let shadow = Color.black.opacity(0.65)

    static let cornerLarge: CGFloat = 24
    static let cornerSmall: CGFloat = 14

    static func fontBody(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    static func fontTitle(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func fontCaption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
}
