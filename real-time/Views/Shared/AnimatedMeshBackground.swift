import SwiftUI

/// A mesh gradient whose interior control points drift continuously.
struct AnimatedMeshBackground: View {
    let colors: [Color]
    let isAnimating: Bool

    /// 30fps rather than 60: the motion is slow enough that the two are
    /// visually identical, and this halves GPU work on a display meant to
    /// stay on for hours.
    private static let framesPerSecond: Double = 30
    private static let frameInterval: Double = 1 / framesPerSecond

    var body: some View {
        // `paused:` rather than swapping views, so the mesh keeps rendering
        // when motion is off instead of being replaced by something else.
        TimelineView(.animation(minimumInterval: Self.frameInterval, paused: !isAnimating)) { context in
            MeshGradient(
                width: MeshPoints.gridSize,
                height: MeshPoints.gridSize,
                points: MeshPoints.points(at: elapsed(at: context.date)),
                colors: colors
            )
            .ignoresSafeArea()
        }
    }

    /// Held at zero when paused, so a still background is always the
    /// undistorted base grid rather than whichever frame it stopped on.
    private func elapsed(at date: Date) -> Double {
        isAnimating ? date.timeIntervalSinceReferenceDate : 0
    }
}
