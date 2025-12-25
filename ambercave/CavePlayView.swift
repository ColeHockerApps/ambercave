import Combine
import SwiftUI

struct CavePlayView: View {

    @EnvironmentObject private var portals: CavePortals
    @EnvironmentObject private var rune: CaveOrientationRune

    let onReady: () -> Void

    @State private var shown: Bool = false

    init(onReady: @escaping () -> Void) {
        self.onReady = onReady
    }

    var body: some View {
        let portalsRef = portals
        let start = portalsRef.restoreResume() ?? portalsRef.playGate

        ZStack {
            Color.black.ignoresSafeArea()

            CavePlay(
                startPoint: start,
                portals: portalsRef,
                rune: rune
            ) {
                if shown == false {
                    shown = true
                    onReady()
                }
            }
            .opacity(shown ? 1 : 0)
            .animation(.easeOut(duration: 0.28), value: shown)
        }
        .onAppear {
            shown = false
        }
    }
}
