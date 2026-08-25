import SwiftUI
import UIKit

/// A clock with no remote input is idle by definition, so without this the
/// tvOS screensaver covers it. Set on appear and cleared on disappear rather
/// than once at launch, so the flag is not held for the app's whole lifetime.
private struct IdleTimerDisabledModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
            .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }
}

extension View {
    func idleTimerDisabled() -> some View {
        modifier(IdleTimerDisabledModifier())
    }
}
