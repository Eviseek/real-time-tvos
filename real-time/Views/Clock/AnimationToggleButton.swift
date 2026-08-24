import SwiftUI

/// Turns background motion on and off. Its label doubles as the state
/// readout, which is why it names the state rather than just the control.
struct AnimationToggleButton: View {
    @Environment(\.settings) private var settings

    private var supportsAnimation: Bool { settings.theme.background.isMesh }

    var body: some View {
        Button(settings.isAnimated ? "Animation: On" : "Animation: Off") {
            settings.isAnimated.toggle()
        }
        // Disabled rather than hidden, so the bar's controls do not appear and
        // vanish as the user browses themes. The type size comes from the bar,
        // so every control in it stays consistent.
        .disabled(!supportsAnimation)
    }
}
