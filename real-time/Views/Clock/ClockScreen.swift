import SwiftUI

struct ClockScreen: View {
    @Environment(\.settings) private var settings

    var body: some View {
        // A stack, so Theme and Timezone push in as their own screens instead
        // of covering the clock in place.
        NavigationStack {
            ZStack {
                // Siblings, never nested: background ticks at 30fps, clock at 1Hz.
                BackgroundView(style: settings.theme.background, isAnimating: settings.isAnimated)
                ClockFace(foreground: settings.clockForeground, timeZone: settings.timeZone)
                SettingsOverlay()
            }
        }
        .idleTimerDisabled()
    }
}
