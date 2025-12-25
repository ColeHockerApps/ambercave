import Combine
import SwiftUI

struct CaveEntryScreen: View {

    @EnvironmentObject private var rune: CaveOrientationRune
    @EnvironmentObject private var haptics: HapticsManager
    @EnvironmentObject private var portals: CavePortals
    @EnvironmentObject private var pathfinder: CavePathfinder

    @State private var showLoading: Bool = true
    @State private var minTimePassed: Bool = false
    @State private var surfaceReady: Bool = false

    @State private var didApplyFirstRotationRule: Bool = false
    @State private var pendingPoint: URL? = nil

    var body: some View {
        ZStack {
            CavePlayView {
                surfaceReady = true
                applyRotationIfPossible()
                tryFinishLoading()
            }
            .opacity(showLoading ? 0 : 1)
            .animation(.easeOut(duration: 0.35), value: showLoading)

            if showLoading {
                CaveEntryScreenLoading()
                    .transition(.opacity)
            }
        }
        .onAppear {
            rune.allowFlexible()

            minTimePassed = false
            surfaceReady = false
            showLoading = true
            didApplyFirstRotationRule = false
            pendingPoint = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + CaveTokens.Motion.loadingMinSeconds) {
                minTimePassed = true
                applyRotationIfPossible()
                tryFinishLoading()
            }
        }
        .onReceive(rune.$activeValue) { next in
            pendingPoint = next
            applyRotationIfPossible()
        }
    }

    private func applyRotationIfPossible() {
        guard didApplyFirstRotationRule == false else { return }
        guard minTimePassed && surfaceReady else { return }
        guard let next = pendingPoint else { return }

        let base = pathfinder.playPortal
        if isSamePortal(next, base) {
            CaveFlowDelegate.shared?.forceLandscape()
        } else {
            CaveFlowDelegate.shared?.clearForced()
        }

        didApplyFirstRotationRule = true
    }

    private func tryFinishLoading() {
        guard minTimePassed && surfaceReady else { return }
        withAnimation(.easeOut(duration: 0.35)) {
            showLoading = false
        }
    }

    private func isSamePortal(_ a: URL, _ b: URL) -> Bool {
        normalize(a) == normalize(b)
    }

    private func normalize(_ u: URL) -> String {
        var s = u.absoluteString
        while s.count > 1, s.hasSuffix("/") { s.removeLast() }
        return s
    }
}

private struct CaveEntryScreenLoading: View {

    @State private var rotate: Double = 0
    @State private var pulse: Bool = false
    @State private var dots: Int = 0

    private let timer = Timer.publish(every: 0.45, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            CavePalette.background
                .ignoresSafeArea()

            VStack(spacing: 28) {

                ZStack {
                    Circle()
                        .stroke(CavePalette.border.opacity(0.25), lineWidth: 2)
                        .frame(width: 64, height: 64)

                    Circle()
                        .fill(CavePalette.accent)
                        .frame(width: 10, height: 10)
                        .offset(y: -32)
                        .rotationEffect(.degrees(rotate))
                }
                .scaleEffect(pulse ? 1.05 : 0.95)

                Text("Loading" + String(repeating: ".", count: dots))
                    .font(CaveTokens.Typography.caption)
                    .foregroundColor(CavePalette.textSecondary)
            }
        }
        .onAppear {
            pulse = true

            withAnimation(
                .linear(duration: 1.2)
                .repeatForever(autoreverses: false)
            ) {
                rotate = 360
            }
        }
        .onReceive(timer) { _ in
            dots = (dots + 1) % 4
        }
    }
}

private struct CaveGlyphWheel: View {
    let t: Double
    let pulse: Bool

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.5)
            let count = 18
            let baseR = side * 0.34

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                CavePalette.accentSoft.opacity(0.28),
                                CavePalette.mist.opacity(0.10),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: side * 0.42
                        )
                    )
                    .frame(width: side * 0.86, height: side * 0.86)
                    .position(center)
                    .scaleEffect(pulse ? 1.03 : 0.98)
                    .blur(radius: 10)
                    .blendMode(.screen)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulse)

                ForEach(0..<count, id: \.self) { i in
                    let a = Double(i) / Double(count) * 2.0 * Double.pi
                    let wobble = (Double(i % 5) - 2.0) * 0.006
                    let r = baseR * (1.0 + CGFloat(wobble)) * (pulse ? 1.02 : 0.98)
                    let phase = a + t * 2.0 * Double.pi

                    CaveShard(i: i, t: t, pulse: pulse)
                        .position(
                            x: center.x + cos(phase) * r,
                            y: center.y + sin(phase) * r
                        )
                        .opacity(pulse ? 1.0 : 0.92)
                }

                Circle()
                    .stroke(CavePalette.border.opacity(0.25), lineWidth: 1)
                    .frame(width: side * 0.66, height: side * 0.66)
                    .position(center)
                    .opacity(0.55)
            }
        }
        .frame(height: 260)
        .allowsHitTesting(false)
    }
}

private struct CaveShard: View {
    let i: Int
    let t: Double
    let pulse: Bool

    var body: some View {
        let size = CGFloat(10 + (i % 4) * 4)
        let stretch = CGFloat(1.25 + Double(i % 3) * 0.16)
        let local = max(0.15, min(1.0, t + Double(i) * 0.018))

        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        CavePalette.accent.opacity(0.95),
                        CavePalette.mist.opacity(0.70),
                        CavePalette.accentSoft.opacity(0.55)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size * stretch, height: size)
            .rotationEffect(.degrees(Double(i * 27) + local * 150))
            .shadow(color: CavePalette.mist.opacity(0.85), radius: 10, x: 0, y: 0)
            .opacity(0.25 + local * 0.75)
            .scaleEffect((pulse ? 1.0 : 0.95) * (0.86 + local * 0.22))
    }
}

private struct CaveChargeBar: View {
    let pulse: Bool
    let t: Double

    @State private var shimmer: CGFloat = -0.9

    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let progress = cappedProgress(from: t)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: h / 2, style: .continuous)
                        .fill(Color.white.opacity(0.08))

                    RoundedRectangle(cornerRadius: h / 2, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    CavePalette.accent.opacity(0.95),
                                    CavePalette.mist.opacity(0.80),
                                    CavePalette.accentSoft.opacity(0.85)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(12, w * progress))
                        .overlay(shimmerOverlay(height: h))
                        .shadow(color: CavePalette.mist.opacity(0.9), radius: 14, x: 0, y: 0)

                    RoundedRectangle(cornerRadius: h / 2, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                }
                .animation(.easeInOut(duration: 0.18), value: progress)
            }
            .frame(height: 14)

            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            CavePalette.mist.opacity(0.55),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .opacity(pulse ? 1.0 : 0.65)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: CaveTokens.Layout.corner, style: .continuous)
                .fill(CavePalette.panel)
                .overlay(
                    RoundedRectangle(cornerRadius: CaveTokens.Layout.corner, style: .continuous)
                        .stroke(CavePalette.border, lineWidth: 1)
                )
                .shadow(color: CavePalette.shadow, radius: 14, x: 0, y: 10)
                .shadow(color: CavePalette.mist.opacity(0.75), radius: 20, x: 0, y: 0)
        )
        .onAppear {
            shimmer = 0.9
        }
    }

    private func cappedProgress(from t: Double) -> Double {
        let raw = t.truncatingRemainder(dividingBy: 1.0)
        let eased = raw < 0.85 ? (raw / 0.85) : (0.96 + (raw - 0.85) * 0.04 / 0.15)
        return min(1.0, max(0.0, eased))
    }

    private func shimmerOverlay(height: CGFloat) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.22),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .rotationEffect(.degrees(18))
            .offset(x: shimmer * 220, y: 0)
            .blendMode(.screen)
            .mask(RoundedRectangle(cornerRadius: height / 2, style: .continuous))
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: false), value: shimmer)
            .allowsHitTesting(false)
    }
}
