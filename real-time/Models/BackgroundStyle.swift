import SwiftUI

/// How a theme fills the screen behind the clock.
enum BackgroundStyle: Hashable, Sendable {
    case solid(Color)

    /// Exactly 9 colors, for a 3x3 `MeshGradient`.
    case mesh([Color])

    /// Only mesh backgrounds have anything to animate, so this gates the
    /// animation toggle in settings.
    var isMesh: Bool {
        if case .mesh = self { return true }
        return false
    }
}
