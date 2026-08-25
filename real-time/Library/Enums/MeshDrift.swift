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

    /// Seconds for one full sweep on each axis — the pace knob. Stated as
    /// periods rather than radians per second so it can be retuned by eye:
    /// raise both to slow the drift, keeping them detuned by a similar ratio
    /// so the axes never resynchronise into a straight diagonal.
    private static let periodX: Double = 120
    private static let periodY: Double = 165

    private static let frequencyX = 2 * Double.pi / periodX
    private static let frequencyY = 2 * Double.pi / periodY

    /// Offsets the vertical sweep so the mesh traces a wandering path rather
    /// than a diagonal line.
    private static let phaseY: Double = 1.7

    /// Shift at `time`, as a fraction of the view in each axis.
    static func offset(at time: Double) -> SIMD2<Double> {
        SIMD2(sin(time * frequencyX) * travel,
              cos(time * frequencyY + phaseY) * travel)
    }
}
