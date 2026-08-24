import SwiftUI

/// Reveals a transient overlay on remote input and hides it again after a
/// pause, so the clock normally shows no chrome at all.
///
/// `revealCount` is incremented on every press purely so `.task(id:)` can key
/// on it: that restarts the countdown and cancels the previous one, with no
/// manual `Task` bookkeeping.
private struct OverlayRevealModifier: ViewModifier {
    @Binding var isVisible: Bool

    @State private var revealCount = 0

    func body(content: Content) -> some View {
        content
            .focusable()
            .onMoveCommand { _ in reveal() }
            .onPlayPauseCommand { reveal() }
            .onTapGesture { reveal() }
            .onExitCommand { hide() }
            .task(id: revealCount) { await hideAfterPause() }
            .animation(OverlayReveal.transition, value: isVisible)
    }

    private func reveal() {
        isVisible = true
        revealCount += 1
    }

    private func hide() {
        withAnimation(OverlayReveal.transition) { isVisible = false }
    }

    private func hideAfterPause() async {
        guard isVisible else { return }
        try? await Task.sleep(for: OverlayReveal.visibleDuration)
        hide()
    }
}

extension View {
    func overlayReveal(isVisible: Binding<Bool>) -> some View {
        modifier(OverlayRevealModifier(isVisible: isVisible))
    }
}
