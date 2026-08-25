import SwiftUI

/// The control bar, hidden after a few seconds of no remote input so it does
/// not compete with the clock, and back the instant the remote is touched.
struct SettingsOverlay: View {
    /// Whichever control holds focus — the signal `hidesWhenIdle` reads.
    private enum Control: Hashable { case theme, timezone, animation }

    @Environment(\.settings) private var settings

    @FocusState private var focusedControl: Control?

    /// How long the bar stays up after the last interaction before it fades.
    private static let hideDelay: Duration = .seconds(5)

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: Metrics.Overlay.buttonSpacing) {
                NavigationLink("Theme") { ThemeGrid() }
                    .focused($focusedControl, equals: .theme)
                NavigationLink("Timezone") { TimeZonePicker() }
                    .focused($focusedControl, equals: .timezone)
                animationToggle
                    .focused($focusedControl, equals: .animation)
            }
            .font(.system(size: Metrics.Overlay.labelFontSize))
            .padding(.horizontal, Metrics.Overlay.horizontalPadding)
            .padding(.vertical, Metrics.Overlay.verticalPadding)
            .glassEffect(.regular, in: .capsule)
        }
        .padding(.top, Metrics.Overlay.topPadding)
        .frame(maxHeight: .infinity, alignment: .top)
        .hidesWhenIdle(after: Self.hideDelay, resetting: focusedControl)
    }

    /// Disabled for the solid themes, which have nothing to animate.
    private var animationToggle: some View {
        Button(settings.isAnimated ? "Animation: On" : "Animation: Off") {
            settings.isAnimated.toggle()
        }
        .disabled(!settings.theme.background.isMesh)
    }
}
