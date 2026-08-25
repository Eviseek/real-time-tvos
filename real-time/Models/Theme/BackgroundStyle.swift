import SwiftUI

/// How a theme fills the screen behind the clock.
enum BackgroundStyle: Hashable, Sendable {
    case solid(Color)

    /// The palette's stops, dark to light — three or four of them. Not the
    /// nine a 3x3 `MeshGradient` needs: those are derived per frame by
    /// `MeshColors`, which is what lets a colour drift across the grid.
    case mesh([Color])

    /// Only mesh backgrounds have anything to animate, so this gates the
    /// animation toggle in settings.
    var isMesh: Bool {
        if case .mesh = self { return true }
        return false
    }
}
