import Foundation

/// Sweeps the whole mesh across the view.
///
/// A pinned boundary is what guarantees the gradient covers the screen — but it
/// also nails the corner colours in place, so no amount of per-point motion can
/// carry a colour from one side of the view to the other. The mesh is therefore
/// drawn larger than the view and slid around beneath it: the pinned edge stays
/// outside the visible area, and every colour crosses the whole screen.
enum MeshDrift {
    /// How much larger than the view the mesh is drawn.
    static let overscan: Double = 1.9

    /// Largest shift, as a fraction of the view. Must stay below
    /// `(overscan - 1) / 2`, or the mesh's pinned edge slides into view and
    /// leaves a hard border. At 1.9 that ceiling is 0.45.
    static let travel: Double = 0.40

    /// Radians per second, detuned so the two axes never resynchronise. Slow
    /// on purpose: a sweep takes roughly 80 and 110 seconds, which reads as
    /// drifting rather than sliding.
    private static let frequencyX: Double = 0.079
    private static let frequencyY: Double = 0.057

    /// Offsets the vertical sweep so the mesh traces a wandering path rather
    /// than a diagonal line.
    private static let phaseY: Double = 1.7

    /// Shift at `time`, as a fraction of the view in each axis.
    static func offset(at time: Double) -> SIMD2<Double> {
        SIMD2(sin(time * frequencyX) * travel,
              cos(time * frequencyY + phaseY) * travel)
    }
}
