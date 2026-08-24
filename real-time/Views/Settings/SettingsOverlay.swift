import SwiftUI

/// The always-visible control bar. Owns only which sheet is up.
struct SettingsOverlay: View {
    @State private var showingThemes = false
    @State private var showingTimeZones = false

    var body: some View {
        VStack {
            // One container so the bar refracts as a single piece of glass
            // rather than as three unrelated slabs.
            GlassEffectContainer {
                HStack(spacing: Metrics.Overlay.buttonSpacing) {
                    Button("Theme") { showingThemes = true }
                    Button("Timezone") { showingTimeZones = true }
                    AnimationToggleButton()
                }
                .padding(.horizontal, Metrics.Overlay.horizontalPadding)
                .padding(.vertical, Metrics.Overlay.verticalPadding)
                .glassEffect(.regular, in: .capsule)
            }
            .padding(.top, Metrics.Overlay.topPadding)

            Spacer()
        }
        .fullScreenCover(isPresented: $showingThemes) { ThemeGrid() }
        .fullScreenCover(isPresented: $showingTimeZones) { TimeZonePicker() }
    }
}
