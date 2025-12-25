//import Combine
//import SwiftUI
//
//struct CaveIntroScreen: View {
//
//    @EnvironmentObject private var router: CavePortals.Router
//    @EnvironmentObject private var haptics: HapticsManager
//    @EnvironmentObject private var rune: CaveOrientationRune
//
//    @State private var appear: Bool = false
//    @State private var drift: CGFloat = -0.18
//    @State private var shimmer: CGFloat = -0.9
//    @State private var pulse: Bool = false
//    @State private var twist: Double = 0
//
//    
//    typealias CavePrimaryButton = CaveWidgets.PrimaryButton
//    typealias CaveSecondaryButton = CaveWidgets.SecondaryButton
//    
//    var body: some View {
//        ZStack {
//            CavePalette.background
//                .ignoresSafeArea()
//
//            ambient
//
//            VStack(spacing: 14) {
//                Spacer()
//
//                titleBlock
//
//                Spacer()
//
//                actions
//                    .padding(.horizontal, 18)
//                    .padding(.bottom, 18)
//            }
//            .opacity(appear ? 1 : 0)
//            .offset(y: appear ? 0 : 10)
//            .animation(.easeOut(duration: 0.45), value: appear)
//        }
//        .onAppear {
//            haptics.prepare()
//            rune.allowFlexible()
//
//            appear = true
//            pulse = true
//
//            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
//                drift = 0.22
//            }
//
//            shimmer = 0.9
//
//            withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
//                twist = Double.pi * 2.0
//            }
//        }
//    }
//
//    private var ambient: some View {
//        GeometryReader { geo in
//            let w = geo.size.width
//            let h = geo.size.height
//            ZStack {
//                Color.black.opacity(0.22)
//
//                orb(
//                    size: min(w, h) * 0.95,
//                    x: w * 0.18,
//                    y: h * 0.20,
//                    a: CavePalette.accent.opacity(0.30),
//                    b: CavePalette.accentSoft.opacity(0.12),
//                    drift: drift
//                )
//
//                orb(
//                    size: min(w, h) * 0.72,
//                    x: w * 0.82,
//                    y: h * 0.38,
//                    a: CavePalette.mist.opacity(0.22),
//                    b: CavePalette.accent.opacity(0.10),
//                    drift: -drift * 0.8
//                )
//
//                orb(
//                    size: min(w, h) * 0.62,
//                    x: w * 0.44,
//                    y: h * 0.74,
//                    a: CavePalette.mist.opacity(0.18),
//                    b: CavePalette.accentSoft.opacity(0.10),
//                    drift: drift * 0.6
//                )
//
//                vignette
//            }
//            .ignoresSafeArea()
//        }
//        .allowsHitTesting(false)
//    }
//
//    private func orb(
//        size: CGFloat,
//        x: CGFloat,
//        y: CGFloat,
//        a: Color,
//        b: Color,
//        drift: CGFloat
//    ) -> some View {
//        Circle()
//            .fill(
//                RadialGradient(
//                    colors: [a, b, Color.clear],
//                    center: .center,
//                    startRadius: 6,
//                    endRadius: size * 0.55
//                )
//            )
//            .frame(width: size, height: size)
//            .position(x: x, y: y)
//            .scaleEffect(pulse ? 1.05 : 0.96)
//            .offset(x: drift * 140, y: drift * 110)
//            .blur(radius: 22)
//            .blendMode(.screen)
//            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: pulse)
//    }
//
//    private var vignette: some View {
//        Rectangle()
//            .fill(
//                RadialGradient(
//                    colors: [
//                        Color.clear,
//                        Color.black.opacity(0.26),
//                        Color.black.opacity(0.64)
//                    ],
//                    center: .center,
//                    startRadius: 180,
//                    endRadius: 820
//                )
//            )
//            .blendMode(.multiply)
//            .allowsHitTesting(false)
//    }
//
//    private var titleBlock: some View {
//        VStack(spacing: 12) {
//            CaveSigil(twist: twist, pulse: pulse)
//                .frame(width: 210, height: 210)
//                .padding(.bottom, 2)
//
//            Text("Ambercave")
//                .font(CaveTokens.Typography.title)
//                .foregroundColor(CavePalette.textPrimary)
//
//            Text("Shoot, merge, and light up the hex field.")
//                .font(CaveTokens.Typography.caption)
//                .foregroundColor(CavePalette.textSecondary)
//        }
//        .padding(.horizontal, 18)
//    }
//
//    private var actions: some View {
//        VStack(spacing: 12) {
//            CavePrimaryButton(title: "Play") {
//                haptics.tapMedium()
//                router.go(.entry)
//            }
//
//            CaveSecondaryButton(title: "Settings") {
//                haptics.tapLight()
//                router.go(.settings)
//            }
//        }
//    }
//}
//
//private struct CaveSigil: View {
//    let twist: Double
//    let pulse: Bool
//
//    var body: some View {
//        GeometryReader { geo in
//            let side = min(geo.size.width, geo.size.height)
//            let c = CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.5)
//            let count = 24
//            let r = side * 0.34
//
//            ZStack {
//                Circle()
//                    .fill(
//                        RadialGradient(
//                            colors: [
//                                CavePalette.accentSoft.opacity(0.30),
//                                CavePalette.mist.opacity(0.10),
//                                Color.clear
//                            ],
//                            center: .center,
//                            startRadius: 8,
//                            endRadius: side * 0.48
//                        )
//                    )
//                    .frame(width: side * 0.98, height: side * 0.98)
//                    .position(c)
//                    .scaleEffect(pulse ? 1.03 : 0.98)
//                    .blur(radius: 12)
//                    .blendMode(.screen)
//                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulse)
//
//                ForEach(0..<count, id: \.self) { i in
//                    let a = Double(i) / Double(count) * 2.0 * Double.pi
//                    let phase = a + twist
//                    let wobble = (Double(i % 6) - 2.5) * 0.005
//                    let rr = r * (1.0 + CGFloat(wobble)) * (pulse ? 1.02 : 0.98)
//
//                    CaveRuneShard(i: i, phase: phase, pulse: pulse)
//                        .position(
//                            x: c.x + cos(phase) * rr,
//                            y: c.y + sin(phase) * rr
//                        )
//                }
//
//                RoundedRectangle(cornerRadius: 18, style: .continuous)
//                    .fill(
//                        LinearGradient(
//                            colors: [
//                                CavePalette.accent.opacity(0.95),
//                                CavePalette.mist.opacity(0.70),
//                                CavePalette.accentSoft.opacity(0.55)
//                            ],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                    .frame(width: side * 0.42, height: side * 0.22)
//                    .rotationEffect(.degrees(22))
//                    .shadow(color: CavePalette.mist.opacity(0.75), radius: 16, x: 0, y: 0)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 18, style: .continuous)
//                            .stroke(CavePalette.border.opacity(0.8), lineWidth: 1)
//                    )
//
//                Rectangle()
//                    .fill(
//                        LinearGradient(
//                            colors: [
//                                Color.clear,
//                                Color.white.opacity(0.16),
//                                Color.clear
//                            ],
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                    )
//                    .rotationEffect(.degrees(18))
//                    .offset(x: shimmerOffset(side: side), y: 0)
//                    .blendMode(.screen)
//                    .mask(
//                        RoundedRectangle(cornerRadius: 18, style: .continuous)
//                            .frame(width: side * 0.42, height: side * 0.22)
//                            .rotationEffect(.degrees(22))
//                    )
//                    .allowsHitTesting(false)
//            }
//        }
//    }
//
//    private func shimmerOffset(side: CGFloat) -> CGFloat {
//        CGFloat(sin(twist * 1.4)) * side * 0.22
//    }
//}
//
//private struct CaveRuneShard: View {
//    let i: Int
//    let phase: Double
//    let pulse: Bool
//
//    var body: some View {
//        let size = CGFloat(7 + (i % 5) * 3)
//        let stretch = CGFloat(1.2 + Double(i % 4) * 0.14)
//        let k = max(0.15, min(1.0, 0.45 + (sin(phase * 1.2) + 1) * 0.25))
//
//        RoundedRectangle(cornerRadius: 6, style: .continuous)
//            .fill(
//                LinearGradient(
//                    colors: [
//                        CavePalette.accent.opacity(0.95),
//                        CavePalette.mist.opacity(0.70),
//                        CavePalette.accentSoft.opacity(0.55)
//                    ],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//            )
//            .frame(width: size * stretch, height: size)
//            .rotationEffect(.degrees(Double(i * 19) + k * 180))
//            .shadow(color: CavePalette.mist.opacity(0.85), radius: 10, x: 0, y: 0)
//            .opacity(0.30 + k * 0.70)
//            .scaleEffect((pulse ? 1.0 : 0.96) * (0.86 + k * 0.20))
//    }
//}
