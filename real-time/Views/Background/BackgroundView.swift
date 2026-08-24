import SwiftUI

/// Renders whichever background the current theme specifies.
///
/// `isAnimating` is accepted even though only mesh backgrounds honour it, so
/// the call site never has to know which kind it is dealing with.
struct BackgroundView: View {
    let style: BackgroundStyle
    let isAnimating: Bool

    var body: some View {
        switch style {
        case .solid(let color):
            color.ignoresSafeArea()
        case .mesh(let colors):
            MeshGradient(
                width: MeshPoints.gridSize,
                height: MeshPoints.gridSize,
                points: MeshPoints.points(at: 0),
                colors: colors
            )
            .ignoresSafeArea()
        }
    }
}
