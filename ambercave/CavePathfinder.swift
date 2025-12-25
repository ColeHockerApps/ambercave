import Combine
import SwiftUI
import Foundation

@MainActor
final class CavePathfinder: ObservableObject {

    @Published var playPortal: URL
    @Published var privacyPortal: URL

    private let playKey = "ambercave.portal.play"
    private let privacyKey = "ambercave.portal.privacy"
    private let resumeKey = "ambercave.portal.resume"
    private let runesKey = "ambercave.portal.runes"

    private var didStoreResume = false

    init() {
        let d = UserDefaults.standard

        let defaultPlay = "https://baranvana.github.io/ambercave"
        let defaultPrivacy = "https://baranvana.github.io/ambercave-game-privacy"

        if let s = d.string(forKey: playKey), let u = URL(string: s) {
            playPortal = u
        } else {
            playPortal = URL(string: defaultPlay)!
        }

        if let s = d.string(forKey: privacyKey), let u = URL(string: s) {
            privacyPortal = u
        } else {
            privacyPortal = URL(string: defaultPrivacy)!
        }
    }

    func setPlayPortal(_ value: String) {
        guard let u = URL(string: value) else { return }
        playPortal = u
        UserDefaults.standard.set(value, forKey: playKey)
    }

    func setPrivacyPortal(_ value: String) {
        guard let u = URL(string: value) else { return }
        privacyPortal = u
        UserDefaults.standard.set(value, forKey: privacyKey)
    }

    func storeResumeIfNeeded(_ portal: URL) {
        guard didStoreResume == false else { return }
        didStoreResume = true

        let d = UserDefaults.standard
        if d.string(forKey: resumeKey) != nil { return }
        d.set(portal.absoluteString, forKey: resumeKey)
    }

    func restoreResume() -> URL? {
        let d = UserDefaults.standard
        guard let s = d.string(forKey: resumeKey), let u = URL(string: s) else { return nil }
        return u
    }

    func saveRunes(_ items: [[String: Any]]) {
        UserDefaults.standard.set(items, forKey: runesKey)
    }

    func loadRunes() -> [[String: Any]]? {
        UserDefaults.standard.array(forKey: runesKey) as? [[String: Any]]
    }

    func resetAll() {
        let d = UserDefaults.standard
        d.removeObject(forKey: playKey)
        d.removeObject(forKey: privacyKey)
        d.removeObject(forKey: resumeKey)
        d.removeObject(forKey: runesKey)
        didStoreResume = false
    }
}
