import SwiftUI
import Combine
import UIKit

@MainActor
final class CaveOrientationRune: ObservableObject {

    static let shared = CaveOrientationRune()

    enum Mode {
        case flexible
        case portrait
        case landscape
    }

    @Published private(set) var mode: Mode = .flexible
    @Published private(set) var activeValue: URL? = nil

     init() {}

    func allowFlexible() {
        mode = .flexible
    }

    func lockPortrait() {
        mode = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    func lockLandscape() {
        mode = .landscape
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    func setActiveValue(_ value: URL?) {
        activeValue = normalizeTrailingSlash(value)
    }

    private func normalizeTrailingSlash(_ url: URL?) -> URL? {
        guard let url else { return nil }

        let scheme = url.scheme?.lowercased() ?? ""
        guard scheme == "http" || scheme == "https" else { return url }

        guard var c = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }

        if c.path.count > 1, c.path.hasSuffix("/") {
            while c.path.count > 1, c.path.hasSuffix("/") {
                c.path.removeLast()
            }
        }

        return c.url ?? url
    }

    var interfaceMask: UIInterfaceOrientationMask {
        switch mode {
        case .flexible:
            return [.portrait, .landscapeLeft, .landscapeRight]
        case .portrait:
            return [.portrait]
        case .landscape:
            return [.landscapeLeft, .landscapeRight]
        }
    }
}
