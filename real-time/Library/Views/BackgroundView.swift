import SwiftUI

/// Renders whichever background the current theme specifies.
///
/// `isAnimating` is accepted even though only mesh backgrounds honour it, so
/// the call site never has to know which kind it is dealing with.
struct BackgroundView: View {
    let style: BackgroundStyle
    let isAnimating: Bool

    /// Continuous full-screen motion is exactly what this setting exists for,
    /// so it overrides the user's animation preference rather than combining
    /// with it as a suggestion.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        switch style {
        case .solid(let color):
            color.ignoresSafeArea()
        case .mesh(let stops):
            AnimatedMeshBackground(stops: stops, isAnimating: isAnimating && !reduceMotion)
        }
    }
}
