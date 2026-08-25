import SwiftUI

/// Fades content out after `delay` with no interaction, and snaps back
/// visible the instant one arrives — either a change in `trigger`, or a raw
/// remote command with nowhere further to move.
///
/// `trigger` (typically a `@FocusState` value from the caller) is the primary
/// signal: on the clock screen the settings bar is the only focusable
/// content, so an ordinary directional press that moves focus between its
/// own controls is consumed entirely by the focus engine and never reaches
/// `onMoveCommand` — only a press at an edge, with nowhere left to move to,
/// does. Watching focus directly is what catches the rest.
private struct HidesWhenIdleModifier<Trigger: Equatable>: ViewModifier {
    let delay: Duration
    let trigger: Trigger

    @State private var isVisible = true
    @State private var interactionCount = 0

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut, value: isVisible)
            .onChange(of: trigger) { _, _ in interactionCount += 1 }
            .onMoveCommand { _ in interactionCount += 1 }
            .onExitCommand { interactionCount += 1 }
            .onPlayPauseCommand { interactionCount += 1 }
            .task(id: interactionCount) {
                isVisible = true
                try? await Task.sleep(for: delay)
                isVisible = false
            }
    }
}

extension View {
    func hidesWhenIdle(after delay: Duration, resetting trigger: some Equatable) -> some View {
        modifier(HidesWhenIdleModifier(delay: delay, trigger: trigger))
    }
}
