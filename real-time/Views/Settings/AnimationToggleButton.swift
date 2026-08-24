import SwiftUI

/// Turns background motion on and off. Keeps its text where the other controls
/// are icon-only, because the label *is* the state readout — no icon can say
/// "on" or "off".
struct AnimationToggleButton: View {
    @Environment(\.settings) private var settings

    private var supportsAnimation: Bool { settings.theme.background.isMesh }

    var body: some View {
        Button(settings.isAnimated ? "Animation: On" : "Animation: Off") {
            settings.isAnimated.toggle()
        }
        .font(.system(size: Metrics.Overlay.labelFontSize))
        // Disabled rather than hidden, so the bar's controls do not appear and
        // vanish as the user browses themes. The disabled appearance carries
        // the message on its own — an inline explanation would be permanently
        // on screen and larger than the rest of the bar combined.
        .disabled(!supportsAnimation)
    }
}
