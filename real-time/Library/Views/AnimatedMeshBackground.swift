import SwiftUI

/// A mesh gradient drawn larger than the view and swept beneath it, so every
/// colour crosses the whole screen rather than sitting in one corner.
///
/// Ticks at 30fps rather than 60: the motion is slow enough that the two are
/// visually identical, and this halves GPU work on a display meant to stay on
/// for hours.
struct AnimatedMeshBackground: View {
    /// The palette's stops; the control-point colors are derived.
    let stops: [Color]
    let isAnimating: Bool

    private static let framesPerSecond: Double = 30
    private static let frameInterval: Double = 1 / framesPerSecond

    var body: some View {
        GeometryReader { proxy in
            // `paused:` rather than swapping views, so the mesh keeps
            // rendering when motion is off instead of being replaced.
            TimelineView(.animation(minimumInterval: Self.frameInterval,
                                    paused: !isAnimating)) { context in
                SweptMesh(stops: stops,
                          moment: elapsed(at: context.date),
                          view: proxy.size)
            }
        }
        .clipped()
        .ignoresSafeArea()
    }

    /// Held at zero when paused, so a still background is always the same
    /// frame rather than whichever one it stopped on.
    private func elapsed(at date: Date) -> Double {
        isAnimating ? date.timeIntervalSinceReferenceDate : 0
    }
}
