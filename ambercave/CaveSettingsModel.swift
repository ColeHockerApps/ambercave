import Combine
import SwiftUI

@MainActor
final class CaveSettingsModel: ObservableObject {

    static let shared = CaveSettingsModel()

    @Published var hapticsEnabled: Bool = true
    @Published var flexibleRotationEnabled: Bool = true

    @Published var resetAlertPresented: Bool = false
    @Published var resetToastShown: Bool = false

    private let hapticsKey = "ambercave.settings.haptics"
    private let rotationKey = "ambercave.settings.rotation"

    private init() {
        let d = UserDefaults.standard

        if d.object(forKey: hapticsKey) == nil {
            hapticsEnabled = true
        } else {
            hapticsEnabled = d.bool(forKey: hapticsKey)
        }

        if d.object(forKey: rotationKey) == nil {
            flexibleRotationEnabled = true
        } else {
            flexibleRotationEnabled = d.bool(forKey: rotationKey)
        }
    }

    func setHapticsEnabled(_ value: Bool) {
        hapticsEnabled = value
        UserDefaults.standard.set(value, forKey: hapticsKey)
    }

    func setFlexibleRotationEnabled(_ value: Bool) {
        flexibleRotationEnabled = value
        UserDefaults.standard.set(value, forKey: rotationKey)
    }

    func requestReset() {
        resetAlertPresented = true
    }

    func cancelReset() {
        resetAlertPresented = false
    }

    func confirmReset(portals: CavePortals) {
        resetAlertPresented = false
        portals.resetAll()

        resetToastShown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.resetToastShown = false
        }
    }
}
