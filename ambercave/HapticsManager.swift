import SwiftUI
import Combine
import UIKit

@MainActor
final class HapticsManager: ObservableObject {

    static let shared = HapticsManager()

    @Published var enabled: Bool {
        didSet { UserDefaults.standard.set(enabled, forKey: keyEnabled) }
    }

    private let keyEnabled = "ambercave.haptics.enabled"

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let select = UISelectionFeedbackGenerator()

    private init() {
        if UserDefaults.standard.object(forKey: keyEnabled) == nil {
            enabled = true
        } else {
            enabled = UserDefaults.standard.bool(forKey: keyEnabled)
        }
    }

    func prepare() {
        guard enabled else { return }
        light.prepare()
        medium.prepare()
        heavy.prepare()
        select.prepare()
    }

    func tapLight() {
        guard enabled else { return }
        light.impactOccurred(intensity: 0.85)
    }

    func tapMedium() {
        guard enabled else { return }
        medium.impactOccurred(intensity: 0.95)
    }

    func tapHeavy() {
        guard enabled else { return }
        heavy.impactOccurred(intensity: 1.0)
    }

    func selectTick() {
        guard enabled else { return }
        select.selectionChanged()
        select.prepare()
    }
}
