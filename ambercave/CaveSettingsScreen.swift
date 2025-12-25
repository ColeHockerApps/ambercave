import Combine
import SwiftUI

struct CaveSettingsScreen: View {

    @EnvironmentObject private var router: CavePathfinder
    @EnvironmentObject private var haptics: HapticsManager
    @EnvironmentObject private var portals: CavePortals
    @EnvironmentObject private var rune: CaveOrientationRune

    @StateObject private var model = CaveSettingsModel.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
//            CavePalette.backdrop
//                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {
                    topBar

                    CaveWidgets.Card {
                        VStack(alignment: .leading, spacing: 10) {
                            headerRow(icon: "slider.horizontal.3", title: "Controls")
                            CaveWidgets.Divider()

                            toggleRow(
                                title: "Haptics",
                                subtitle: "Small taps and feedback",
                                isOn: Binding(
                                    get: { model.hapticsEnabled },
                                    set: { v in
                                        model.setHapticsEnabled(v)
                                        haptics.enabled = v
                                        haptics.tapLight()
                                    }
                                )
                            )

                            CaveWidgets.Divider()

                            toggleRow(
                                title: "Flexible rotation",
                                subtitle: "Allow any orientation",
                                isOn: Binding(
                                    get: { model.flexibleRotationEnabled },
                                    set: { v in
                                        model.setFlexibleRotationEnabled(v)
                                        haptics.tapLight()
                                        if v { rune.allowFlexible() } else { rune.lockLandscape() }
                                    }
                                )
                            )
                        }
                    }

                    CaveWidgets.Card {
                        VStack(alignment: .leading, spacing: 10) {
                            headerRow(icon: "hand.raised.fill", title: "Privacy")
                            CaveWidgets.Divider()
//
//                            CaveWidgets.PrimaryButton(title: "Open Privacy Policy") {
//                                haptics.tapLight()
//                                portals.openPrivacy()
//                            }
                        }
                    }

                    CaveWidgets.Card {
                        VStack(alignment: .leading, spacing: 10) {
                            headerRow(icon: "trash.fill", title: "Data")
                            CaveWidgets.Divider()

                            CaveWidgets.PrimaryButton(title: "Reset Progress") {
                                haptics.tapMedium()
                                model.requestReset()
                            }
                        }
                    }

                    Spacer(minLength: 18)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 18)
            }

            if model.resetToastShown {
                toastView(text: "Reset complete")
                    .transition(.opacity)
            }
        }
        .alert("Reset Progress", isPresented: $model.resetAlertPresented) {
            Button("Cancel", role: .cancel) {
                haptics.tapLight()
                model.cancelReset()
            }
            Button("Reset", role: .destructive) {
                haptics.tapHeavy()
                model.confirmReset(portals: portals)
            }
        } message: {
            Text("This will clear saved progress and resume state on this device.")
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

            Text("Settings")
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

    private func headerRow(icon: String, title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(CavePalette.textPrimary)

            Text(title)
                .font(CavePalette.fontTitle())
                .foregroundColor(CavePalette.textPrimary)

            Spacer()
        }
    }

    private func toggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(CavePalette.fontBody(15))
                    .foregroundColor(CavePalette.textPrimary)

                Text(subtitle)
                    .font(CavePalette.fontBody(12))
                    .foregroundColor(CavePalette.textSecondary)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(CavePalette.accent)
                .onChange(of: isOn.wrappedValue) { _ in
                    haptics.tapLight()
                }
        }
        .padding(.vertical, 4)
    }

    private func toastView(text: String) -> some View {
        VStack {
            Spacer()

            Text(text)
                .font(CavePalette.fontBody(13))
                .foregroundColor(CavePalette.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(CavePalette.surfaceStrong)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(CavePalette.borderSoft, lineWidth: 1)
                        )
                        .shadow(color: CavePalette.shadow, radius: 12, x: 0, y: 8)
                )
                .padding(.bottom, 18)
        }
        .padding(.horizontal, 16)
        .allowsHitTesting(false)
        .animation(.easeOut(duration: 0.2), value: model.resetToastShown)
    }
}
