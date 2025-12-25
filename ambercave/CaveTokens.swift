import SwiftUI
import Combine

enum CaveTokens {

    enum Motion {
        static let loadingMinSeconds: Double = 2.2
        static let fadeOutSeconds: Double = 0.32
    }

    enum Layout {
        static let corner: CGFloat = 22
    }

    enum Typography {
        static let title: Font = .system(size: 22, weight: .semibold, design: .rounded)
        static let body: Font = .system(size: 15, weight: .medium, design: .rounded)
        static let caption: Font = .system(size: 13, weight: .regular, design: .rounded)
    }

    enum Storage {
        static let playPointKey = "ambercave.portal.play"
        static let privacyPointKey = "ambercave.portal.privacy"
        static let trailPointKey = "ambercave.portal.trail"
        static let marksKey = "ambercave.portal.marks"
    }

    enum Defaults {
        static let playGate: String = "https://baranvana.github.io/ambercave"
        static let privacyGate: String = "https://baranvana.github.io/ambercave-game-privacy"
    }
}
