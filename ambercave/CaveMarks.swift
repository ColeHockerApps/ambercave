import SwiftUI
import Combine

@MainActor
final class CaveMarks: ObservableObject {

    static let shared = CaveMarks()

    @Published private(set) var entryStone: URL?
    @Published private(set) var lastStone: URL?

    private let entryKey = "ambercave.stone.entry"
    private let lastKey = "ambercave.stone.last"

    private init() {
        restore()
    }

    func setEntryStone(_ value: URL) {
        entryStone = value
        UserDefaults.standard.set(value.absoluteString, forKey: entryKey)
    }

    func setLastStone(_ value: URL?) {
        lastStone = value
        if let value {
            UserDefaults.standard.set(value.absoluteString, forKey: lastKey)
        } else {
            UserDefaults.standard.removeObject(forKey: lastKey)
        }
    }

    func restore() {
        if let s = UserDefaults.standard.string(forKey: entryKey),
           let v = URL(string: s) {
            entryStone = v
        }

        if let s = UserDefaults.standard.string(forKey: lastKey),
           let v = URL(string: s) {
            lastStone = v
        }
    }

    func reset() {
        entryStone = nil
        lastStone = nil
        UserDefaults.standard.removeObject(forKey: entryKey)
        UserDefaults.standard.removeObject(forKey: lastKey)
    }
}
