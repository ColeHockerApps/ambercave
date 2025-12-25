import SwiftUI
import Combine
import UIKit

final class CaveFlowDelegate: NSObject, UIApplicationDelegate {

    static weak var shared: CaveFlowDelegate?

    private var forcedMask: UIInterfaceOrientationMask? = nil
    private var pending: DispatchWorkItem?
    private var lastApplied: UIInterfaceOrientationMask? = nil
    private var isApplying: Bool = false

    override init() {
        super.init()
        CaveFlowDelegate.shared = self
    }

    func forceLandscape() {
        scheduleApply(mask: [.landscapeLeft, .landscapeRight], rotateTo: .landscapeRight)
    }

    func clearForced() {
        scheduleApply(mask: nil, rotateTo: nil)
    }

    private func scheduleApply(mask: UIInterfaceOrientationMask?, rotateTo: UIInterfaceOrientation?) {
        if isApplying { return }
        if lastApplied == mask { return }

        pending?.cancel()

        let job = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.isApplying = true
            self.forcedMask = mask
            self.lastApplied = mask

            if let rotateTo {
                UIDevice.current.setValue(rotateTo.rawValue, forKey: "orientation")
            }
            UIViewController.attemptRotationToDeviceOrientation()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.isApplying = false
            }
        }

        pending = job
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22, execute: job)
    }

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        forcedMask ?? [.portrait, .landscapeLeft, .landscapeRight]
    }
}
