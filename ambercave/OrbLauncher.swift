import Foundation
import Combine
import CoreGraphics

@MainActor
final class OrbLauncher: ObservableObject {

    @Published private(set) var aimAngle: CGFloat = 0
    @Published private(set) var power: CGFloat = 0.65

    var minPower: CGFloat = 0.25
    var maxPower: CGFloat = 1.0

    var minAngle: CGFloat = -CGFloat.pi * 0.48
    var maxAngle: CGFloat = CGFloat.pi * 0.48

    var muzzle: CGPoint = .zero
    var baseSpeed: CGFloat = 820

    private var cooldownUntil: TimeInterval = 0
    var cooldown: TimeInterval = 0.12

    init() {}

    func setMuzzle(_ point: CGPoint) {
        muzzle = point
    }

    func setAimAngle(_ radians: CGFloat) {
        aimAngle = clamp(radians, minAngle, maxAngle)
    }

    func nudgeAim(delta: CGFloat) {
        setAimAngle(aimAngle + delta)
    }

    func setPowerNormalized(_ value: CGFloat) {
        power = clamp(value, minPower, maxPower)
    }

    func canFire(now: TimeInterval) -> Bool {
        now >= cooldownUntil
    }

    func fire(kind: MarbleOrb.Kind, now: TimeInterval, radius: CGFloat = 16) -> MarbleOrb? {
        guard canFire(now: now) else { return nil }

        cooldownUntil = now + cooldown

        let dir = CGVector(dx: cos(aimAngle), dy: sin(aimAngle))
        let speed = baseSpeed * power
        let vel = CGVector(dx: dir.dx * speed, dy: dir.dy * speed)

        return MarbleOrb(
            kind: kind,
            position: muzzle,
            velocity: vel,
            radius: radius,
            isActive: true
        )
    }

    private func clamp(_ v: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat {
        min(hi, max(lo, v))
    }
}
