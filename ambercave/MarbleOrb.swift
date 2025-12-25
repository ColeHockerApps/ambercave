import Foundation
import CoreGraphics

struct MarbleOrb: Identifiable, Hashable {

    enum Kind: String, CaseIterable {
        case red
        case orange
        case yellow
        case green
        case cyan
        case blue
        case purple

        static func random() -> Kind {
            Kind.allCases.randomElement() ?? .blue
        }
    }

    let id: UUID
    var kind: Kind

    var position: CGPoint
    var velocity: CGVector

    var radius: CGFloat
    var isActive: Bool

    init(
        id: UUID = UUID(),
        kind: Kind,
        position: CGPoint,
        velocity: CGVector,
        radius: CGFloat,
        isActive: Bool = true
    ) {
        self.id = id
        self.kind = kind
        self.position = position
        self.velocity = velocity
        self.radius = radius
        self.isActive = isActive
    }

    mutating func step(dt: CGFloat, friction: CGFloat = 0.985) {
        guard isActive else { return }

        position.x += velocity.dx * dt
        position.y += velocity.dy * dt

        velocity.dx *= friction
        velocity.dy *= friction
    }

    mutating func applyImpulse(_ impulse: CGVector) {
        guard isActive else { return }
        velocity.dx += impulse.dx
        velocity.dy += impulse.dy
    }

    func distance(to p: CGPoint) -> CGFloat {
        let dx = position.x - p.x
        let dy = position.y - p.y
        return sqrt(dx * dx + dy * dy)
    }
}
