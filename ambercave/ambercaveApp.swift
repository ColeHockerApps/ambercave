import SwiftUI
import Combine

@main
struct AmbercaveApp: App {

    @UIApplicationDelegateAdaptor(CaveFlowDelegate.self) private var flow

    //@StateObject private var haptics = HapticsManager()
    @StateObject private var portals = CavePortals()
    @StateObject private var rune = CaveOrientationRune()
    @StateObject private var pathfinder = CavePathfinder()

    var body: some Scene {
        WindowGroup {
            CaveEntryScreen()
                //.environmentObject(haptics)
                .environmentObject(portals)
                .environmentObject(rune)
                .environmentObject(pathfinder)
        }
    }
}
