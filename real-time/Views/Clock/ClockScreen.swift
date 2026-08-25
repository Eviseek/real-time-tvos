import SwiftUI

struct ClockScreen: View {
    @Environment(\.settings) private var settings

    var body: some View {
        NavigationStack {
            ZStack {
                // Siblings, never nested: background ticks at 30fps, clock at 1Hz.
                BackgroundView(style: settings.theme.background, isAnimating: settings.isAnimated)
                ClockFace(color: settings.clockColor, timeZone: settings.timeZone)
                SettingsOverlay()
            }
        }
        .idleTimerDisabled()
    }
}
