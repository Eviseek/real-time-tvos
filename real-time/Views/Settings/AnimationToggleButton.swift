import SwiftUI

/// Turns background motion on and off.
struct AnimationToggleButton: View {
    @Environment(\.settings) private var settings

    private var supportsAnimation: Bool { settings.theme.background.isMesh }

    var body: some View {
        VStack(spacing: Metrics.Overlay.captionSpacing) {
            Button(settings.isAnimated ? "Animation: On" : "Animation: Off") {
                settings.isAnimated.toggle()
            }
            // Disabled rather than hidden, so the bar's controls do not appear
            // and vanish as the user browses themes.
            .disabled(!supportsAnimation)

            if !supportsAnimation {
                Text("Solid themes have nothing to flow")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
