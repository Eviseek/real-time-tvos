import SwiftUI

struct ClockScreen: View {
    @Environment(\.settings) private var settings

    @State private var isOverlayVisible = false

    var body: some View {
        ZStack {
            // Siblings, never nested: background ticks at 30fps, clock at 1Hz.
            BackgroundView(style: settings.theme.background, isAnimating: settings.isAnimated)
            ClockFace(theme: settings.theme, timeZone: settings.timeZone)

            if isOverlayVisible {
                SettingsOverlay()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .overlayReveal(isVisible: $isOverlayVisible)
        .idleTimerDisabled()
    }
}
