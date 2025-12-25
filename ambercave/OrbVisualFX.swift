import Combine
import SwiftUI

@MainActor
final class OrbFXBus: ObservableObject {

    static let shared = OrbFXBus()

    struct Burst: Identifiable, Equatable {
        let id = UUID()
        let at: CGPoint
        let tint: Color
        let strength: Double
        let createdAt: TimeInterval
    }

    struct Pulse: Identifiable, Equatable {
        let id = UUID()
        let at: CGPoint
        let tint: Color
        let radius: CGFloat
        let createdAt: TimeInterval
    }

    struct TrailDot: Identifiable, Equatable {
        let id = UUID()
        let at: CGPoint
        let tint: Color
        let size: CGFloat
        let createdAt: TimeInterval
    }

    @Published private(set) var bursts: [Burst] = []
    @Published private(set) var pulses: [Pulse] = []
    @Published private(set) var trails: [TrailDot] = []

    private init() {}

    func emitBurst(at: CGPoint, tint: Color, strength: Double = 1.0) {
        bursts.append(Burst(at: at, tint: tint, strength: max(0.2, min(2.0, strength)), createdAt: now()))
        trim()
    }

    func emitPulse(at: CGPoint, tint: Color, radius: CGFloat = 54) {
        pulses.append(Pulse(at: at, tint: tint, radius: max(24, min(140, radius)), createdAt: now()))
        trim()
    }

    func emitTrail(at: CGPoint, tint: Color, size: CGFloat = 8) {
        trails.append(TrailDot(at: at, tint: tint, size: max(3, min(18, size)), createdAt: now()))
        trim()
    }

    func clearAll() {
        bursts.removeAll()
        pulses.removeAll()
        trails.removeAll()
    }

    private func trim() {
        if bursts.count > 16 { bursts.removeFirst(bursts.count - 16) }
        if pulses.count > 12 { pulses.removeFirst(pulses.count - 12) }
        if trails.count > 90 { trails.removeFirst(trails.count - 90) }
    }

    private func now() -> TimeInterval {
        Date().timeIntervalSince1970
    }
}

struct OrbVisualFX: View {

    @ObservedObject var bus: OrbFXBus

    init(bus: OrbFXBus = .shared) {
        self.bus = bus
    }

    var body: some View {
        TimelineView(.animation) { ctx in
            Canvas { context, size in
                let t = ctx.date.timeIntervalSince1970

                drawTrails(in: context, t: t)
                drawPulses(in: context, t: t)
                drawBursts(in: context, t: t)
            }
            .allowsHitTesting(false)
//            .onChange(of: ctx.date) { _ in
//                prune(at: tValue(ctx.date))
//            }
        }
    }

    private func tValue(_ d: Date) -> TimeInterval {
        d.timeIntervalSince1970
    }

    private func prune(at t: TimeInterval) {
        let burstLife: TimeInterval = 0.48
        let pulseLife: TimeInterval = 0.62
        let trailLife: TimeInterval = 0.42

//        bus.bursts = bus.bursts.filter { (t - $0.createdAt) <= burstLife }
//        bus.pulses = bus.pulses.filter { (t - $0.createdAt) <= pulseLife }
//        bus.trails = bus.trails.filter { (t - $0.createdAt) <= trailLife }
    }

    private func drawTrails(in context: GraphicsContext, t: TimeInterval) {
        let life: TimeInterval = 0.42

        for dot in bus.trails {
            let age = t - dot.createdAt
            if age < 0 || age > life { continue }

            let p = age / life
            let alpha = (1.0 - p) * 0.55
            let s = dot.size * CGFloat(0.85 + (1.0 - p) * 0.35)

            let rect = CGRect(x: dot.at.x - s * 0.5, y: dot.at.y - s * 0.5, width: s, height: s)
            var path = Path(ellipseIn: rect)

            context.fill(
                path,
                with: .radialGradient(
                    Gradient(colors: [
                        dot.tint.opacity(alpha),
                        dot.tint.opacity(alpha * 0.25),
                        .clear
                    ]),
                    center: dot.at,
                    startRadius: 0,
                    endRadius: s * 1.4
                )
            )
        }
    }

    private func drawPulses(in context: GraphicsContext, t: TimeInterval) {
        let life: TimeInterval = 0.62

        for pulse in bus.pulses {
            let age = t - pulse.createdAt
            if age < 0 || age > life { continue }

            let p = age / life
            let eased = easeOut(p)

            let r = pulse.radius * CGFloat(0.55 + eased * 0.75)
            let alpha = (1.0 - p) * 0.55

            var ring = Path()
            ring.addEllipse(in: CGRect(x: pulse.at.x - r, y: pulse.at.y - r, width: r * 2, height: r * 2))

            context.stroke(
                ring,
                with: .color(pulse.tint.opacity(alpha)),
                style: StrokeStyle(lineWidth: max(1.0, 3.2 - CGFloat(p) * 2.2), lineCap: .round, lineJoin: .round)
            )

            let innerR = r * 0.72
            var glow = Path()
            glow.addEllipse(in: CGRect(x: pulse.at.x - innerR, y: pulse.at.y - innerR, width: innerR * 2, height: innerR * 2))

            context.fill(
                glow,
                with: .radialGradient(
                    Gradient(colors: [
                        pulse.tint.opacity(alpha * 0.22),
                        pulse.tint.opacity(alpha * 0.08),
                        .clear
                    ]),
                    center: pulse.at,
                    startRadius: 0,
                    endRadius: r * 1.25
                )
            )
        }
    }

    private func drawBursts(in context: GraphicsContext, t: TimeInterval) {
        let life: TimeInterval = 0.48

        for b in bus.bursts {
            let age = t - b.createdAt
            if age < 0 || age > life { continue }

            let p = age / life
            let eased = easeOut(p)

            let count = 10
            let baseR: CGFloat = 10
            let spread: CGFloat = 46 * CGFloat(b.strength)

            for i in 0..<count {
                let a = (Double(i) / Double(count)) * 2.0 * Double.pi
                let radial = baseR + spread * CGFloat(eased)

                let x = b.at.x + cos(a) * radial
                let y = b.at.y + sin(a) * radial

                let size = CGFloat(3.0 + (Double((i % 3) + 1)) * 1.6) * CGFloat(1.0 - p * 0.7)
                let alpha = (1.0 - p) * 0.85

                let rect = CGRect(x: x - size * 0.5, y: y - size * 0.5, width: size, height: size)
                let dot = Path(ellipseIn: rect)

                context.fill(dot, with: .color(b.tint.opacity(alpha)))
            }

            let coreR = CGFloat(10 + 18 * b.strength) * CGFloat(1.0 - p * 0.55)
            let coreAlpha = (1.0 - p) * 0.45

            var core = Path()
            core.addEllipse(in: CGRect(x: b.at.x - coreR, y: b.at.y - coreR, width: coreR * 2, height: coreR * 2))

            context.fill(
                core,
                with: .radialGradient(
                    Gradient(colors: [
                        b.tint.opacity(coreAlpha),
                        b.tint.opacity(coreAlpha * 0.25),
                        .clear
                    ]),
                    center: b.at,
                    startRadius: 0,
                    endRadius: coreR * 1.6
                )
            )
        }
    }

    private func easeOut(_ x: Double) -> Double {
        let t = max(0.0, min(1.0, x))
        return 1.0 - pow(1.0 - t, 2.2)
    }
}

struct OrbFXAttach: ViewModifier {

    let bus: OrbFXBus

    func body(content: Content) -> some View {
        content.overlay(OrbVisualFX(bus: bus))
    }
}

extension View {
    func orbFX(_ bus: OrbFXBus = .shared) -> some View {
        modifier(OrbFXAttach(bus: bus))
    }
}
