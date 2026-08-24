import SwiftUI

/// One icon-only control in the settings bar.
struct SettingsBarIcon: View {
    let title: String
    let systemImage: String

    var body: some View {
        // `.iconOnly` rather than a bare `Image`: the text is dropped
        // visually but kept as the accessibility label, so the button still
        // announces itself to VoiceOver.
        Label(title, systemImage: systemImage)
            .labelStyle(.iconOnly)
            .font(.system(size: Metrics.Overlay.iconSize))
    }
}
