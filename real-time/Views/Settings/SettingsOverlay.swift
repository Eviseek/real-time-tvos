import SwiftUI

/// The control bar. Owns only which sheet is up; whether the bar itself is
/// visible belongs to the screen that reveals it.
struct SettingsOverlay: View {
    @State private var showingThemes = false
    @State private var showingTimeZones = false

    var body: some View {
        VStack {
            HStack(spacing: Metrics.Overlay.buttonSpacing) {
                Button("Theme") { showingThemes = true }
                Button("Timezone") { showingTimeZones = true }
                AnimationToggleButton()
            }
            .padding(.horizontal, Metrics.Overlay.horizontalPadding)
            .padding(.vertical, Metrics.Overlay.verticalPadding)
            .background(.thinMaterial, in: .capsule)
            .padding(.top, Metrics.Overlay.topPadding)

            Spacer()
        }
        .fullScreenCover(isPresented: $showingThemes) { ThemeGrid() }
        .fullScreenCover(isPresented: $showingTimeZones) { TimeZonePicker() }
    }
}
