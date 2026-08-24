import SwiftUI

/// The always-visible control bar: icons for the two screens, text for the one
/// control whose state you need to read at a glance.
struct SettingsOverlay: View {
    var body: some View {
        VStack {
            // One container so the bar refracts as a single piece of glass
            // rather than as three unrelated slabs.
            GlassEffectContainer {
                HStack(spacing: Metrics.Overlay.buttonSpacing) {
                    NavigationLink {
                        ThemeGrid()
                    } label: {
                        SettingsBarIcon(title: "Theme", systemImage: "paintpalette")
                    }
                    NavigationLink {
                        TimeZonePicker()
                    } label: {
                        SettingsBarIcon(title: "Timezone", systemImage: "globe")
                    }
                    AnimationToggleButton()
                }
                .padding(.horizontal, Metrics.Overlay.horizontalPadding)
                .padding(.vertical, Metrics.Overlay.verticalPadding)
                .glassEffect(.regular, in: .capsule)
            }
            .padding(.top, Metrics.Overlay.topPadding)

            Spacer()
        }
    }
}
