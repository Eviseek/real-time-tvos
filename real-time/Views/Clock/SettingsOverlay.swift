import SwiftUI

/// The always-visible control bar.
struct SettingsOverlay: View {
    var body: some View {
        // One container so the bar refracts as a single piece of glass rather
        // than as three unrelated slabs.
        GlassEffectContainer {
            HStack(spacing: Metrics.Overlay.buttonSpacing) {
                NavigationLink("Theme") { ThemeGrid() }
                NavigationLink("Timezone") { TimeZonePicker() }
                AnimationToggleButton()
            }
            // Set once for the whole bar rather than on each control, so the
            // three buttons cannot drift apart in size.
            .font(.system(size: Metrics.Overlay.labelFontSize))
            .padding(.horizontal, Metrics.Overlay.horizontalPadding)
            .padding(.vertical, Metrics.Overlay.verticalPadding)
            .glassEffect(.regular, in: .capsule)
        }
        .padding(.top, Metrics.Overlay.topPadding)
        // Pins the bar to the top of the clock screen. Horizontal centring
        // comes from the ZStack it sits in.
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
