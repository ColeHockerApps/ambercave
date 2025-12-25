import Combine
import SwiftUI
import SafariServices

struct CavePrivacyScreen: View {

    @EnvironmentObject private var haptics: HapticsManager
    @EnvironmentObject private var portals: CavePortals
    @EnvironmentObject private var rune: CaveOrientationRune

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
//            CavePalette.backdrop
//                .ignoresSafeArea()

            VStack(spacing: 14) {
                topBar

                CaveWidgets.Card {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(CavePalette.textPrimary)

                            Text("Privacy Policy")
                                .font(CavePalette.fontTitle())
                                .foregroundColor(CavePalette.textPrimary)

                            Spacer()
                        }

                        CaveWidgets.Divider()

                        Text("This page opens the privacy policy in your browser.")
                            .font(CavePalette.fontBody(14))
                            .foregroundColor(CavePalette.textSecondary)

//                        CaveWidgets.PrimaryButton(title: "Open Privacy Policy") {
//                            haptics.tapLight()
//                            portals.openPrivacy()
//                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 18)
        }
        .onAppear {
            rune.allowFlexible()
        }
    }

    private var topBar: some View {
        HStack {
            CaveWidgets.IconButton(systemName: "chevron.left") {
                haptics.tapLight()
                dismiss()
            }

            Spacer()

            Text("Privacy")
                .font(CavePalette.fontBody(16))
                .foregroundColor(CavePalette.textPrimary.opacity(0.9))

            Spacer()

            CaveWidgets.IconButton(systemName: "xmark") {
                haptics.tapLight()
                dismiss()
            }
        }
        .padding(.top, 6)
    }
}
