import SwiftUI
import Combine

enum CaveWidgets {

    struct PrimaryButton: View {
        let title: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(CavePalette.fontBody(16))
                    .foregroundColor(CavePalette.textPrimary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(CavePalette.accent)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(CavePalette.borderSoft, lineWidth: 1)
                            .opacity(0.6)
                    )
                    .shadow(color: CavePalette.shadow, radius: 10, x: 0, y: 8)
            }
            .buttonStyle(.plain)
        }
    }

    struct SecondaryButton: View {
        let title: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(CavePalette.fontBody(16))
                    .foregroundColor(CavePalette.textPrimary.opacity(0.92))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(CavePalette.surfaceStrong)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(CavePalette.borderSoft, lineWidth: 1)
                            .opacity(0.75)
                    )
                    .shadow(color: CavePalette.shadow, radius: 10, x: 0, y: 8)
            }
            .buttonStyle(.plain)
        }
    }

    struct IconButton: View {
        let systemName: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: systemName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(CavePalette.textPrimary)
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(CavePalette.surfaceStrong.opacity(0.92))
                    )
                    .overlay(
                        Circle()
                            .stroke(CavePalette.borderSoft, lineWidth: 1)
                            .opacity(0.7)
                    )
                    .shadow(color: CavePalette.shadow, radius: 10, x: 0, y: 8)
            }
            .buttonStyle(.plain)
        }
    }

    struct Card<Content: View>: View {
        let content: Content

        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }

        var body: some View {
            content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(CavePalette.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(CavePalette.borderSoft, lineWidth: 1)
                        )
                )
                .shadow(color: CavePalette.shadow, radius: 12, x: 0, y: 10)
        }
    }

    struct Divider: View {
        var body: some View {
            Rectangle()
                .fill(CavePalette.borderSoft)
                .frame(height: 1)
                .opacity(0.55)
        }
    }
}
