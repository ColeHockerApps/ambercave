import Foundation
import Combine

@MainActor
final class CavePortals: ObservableObject {

    final class Router: ObservableObject {

        enum Route: Equatable {
            case intro
            case entry
            case play
            case settings
            case privacy
        }

        @Published var route: Route = .intro

        func go(_ next: Route) {
            route = next
        }
    }

    @Published var playGate: URL
    @Published var privacyGate: URL

    private let playKey = "ambercave.portal.play"
    private let privacyKey = "ambercave.portal.privacy"
    private let resumeKey = "ambercave.portal.resume"
    private let marksKey = "ambercave.portal.marks"

    private var didStoreResume = false

    init() {
        let defaults = UserDefaults.standard

        let defaultPlay = CaveTokens.Defaults.playGate
        let defaultPrivacy = CaveTokens.Defaults.privacyGate

        if let saved = defaults.string(forKey: playKey),
           let v = URL(string: saved) {
            playGate = v
        } else {
            playGate = URL(string: defaultPlay)!
        }

        if let saved = defaults.string(forKey: privacyKey),
           let v = URL(string: saved) {
            privacyGate = v
        } else {
            privacyGate = URL(string: defaultPrivacy)!
        }
    }

    func updatePlay(_ value: String) {
        guard let v = URL(string: value) else { return }
        playGate = v
        UserDefaults.standard.set(value, forKey: playKey)
    }

    func updatePrivacy(_ value: String) {
        guard let v = URL(string: value) else { return }
        privacyGate = v
        UserDefaults.standard.set(value, forKey: privacyKey)
    }

    func storeResumeIfNeeded(_ point: URL) {
        guard didStoreResume == false else { return }
        didStoreResume = true

        let defaults = UserDefaults.standard
        if defaults.string(forKey: resumeKey) != nil { return }
        defaults.set(point.absoluteString, forKey: resumeKey)
    }

    func restoreResume() -> URL? {
        let defaults = UserDefaults.standard
        if let saved = defaults.string(forKey: resumeKey),
           let v = URL(string: saved) {
            return v
        }
        return nil
    }

    func saveMarks(_ items: [[String: Any]]) {
        UserDefaults.standard.set(items, forKey: marksKey)
    }

    func loadMarks() -> [[String: Any]]? {
        UserDefaults.standard.array(forKey: marksKey) as? [[String: Any]]
    }

    func resetAll() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: playKey)
        defaults.removeObject(forKey: privacyKey)
        defaults.removeObject(forKey: resumeKey)
        defaults.removeObject(forKey: marksKey)
        didStoreResume = false
    }

    func normalize(_ u: URL) -> String {
        var s = u.absoluteString
        while s.count > 1, s.hasSuffix("/") { s.removeLast() }
        return s
    }
}
