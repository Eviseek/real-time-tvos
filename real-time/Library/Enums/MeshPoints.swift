import Foundation

/// Control-point geometry for the mesh background.
///
/// Pure math with no SwiftUI dependency, so it can be reasoned about without
/// rendering anything.
///
/// All phase arithmetic is deliberately `Double`, and only the final position
/// narrows to `Float`. `MeshGradient` wants `SIMD2<Float>`, but the time value
/// fed in is `timeIntervalSinceReferenceDate` — on the order of 8x10^8, where
/// a `Float`'s ulp is **64 seconds**. Converting the timestamp first freezes
/// the animation for a minute at a stretch and then jumps it.
enum MeshPoints {
    /// Grid width and height.
    ///
    /// 5 rather than 3 because the view only shows part of the mesh now (see
    /// `MeshDrift`). On a 3x3 the palette's diagonal spans just five bands, so
    /// a window over half the mesh could not hold every stop; at 5x5 the bands
    /// repeat and every colour stays on screen wherever the mesh has drifted.
    static let gridSize = 5

    /// Total control points, and the number of colors `MeshGradient` requires.
    static let pointCount = gridSize * gridSize

    /// Distance between neighbouring points, in unit-square terms.
    private static let spacing = 1 / Double(gridSize - 1)

    /// How far a point may drift from its base position.
    ///
    /// Must stay below half of `spacing`: past that, neighbouring points cross,
    /// the grid stops being monotone and the mesh folds over itself. The global
    /// sweep in `MeshDrift` is what carries colours across the view; this is
    /// only the local churn on top of it.
    static let defaultAmplitude: Double = 0.09

    /// Multiplies every point frequency. The distance knob is `amplitude`;
    /// this is the pace knob for the local churn, as `MeshDrift`'s periods are
    /// for the sweep. Both were slowed by half again together, so the churn
    /// stays in proportion to the sweep rather than becoming the busier of the
    /// two.
    static let speed: Double = 2.0

    /// A second harmonic is added to each axis at this fraction of the base
    /// frequency. A single sine traces the same straight line forever, which
    /// reads as a pendulum; two detuned sines wander and never quite retrace.
    private static let harmonicRatio: Double = 0.37

    /// How much of the travel the second harmonic contributes.
    private static let harmonicWeight: Double = 0.45

    /// `MeshGradient` is defined over the unit square. A point outside it
    /// leaves part of the mesh with no defined color.
    private static let domain: ClosedRange<Double> = 0...1

    static func points(at time: Double, amplitude: Double = defaultAmplitude) -> [SIMD2<Float>] {
        let elapsed = time * speed
        return (0..<pointCount).map { index in
            let row = index / gridSize
            let column = index % gridSize
            let base = SIMD2(Double(column) * spacing, Double(row) * spacing)
            let travel = SIMD2(
                wander(elapsed, index, axis: 0, wave: sin),
                wander(elapsed, index, axis: 1, wave: cos)
            ) * amplitude * freedom(row: row, column: column)
            let moved = base + travel
            return SIMD2(Float(moved.x.clamped(to: domain)),
                         Float(moved.y.clamped(to: domain)))
        }
    }

    /// Which axes a point may travel on: 1 is free, 0 is pinned.
    ///
    /// The mesh's outer boundary is the drawn region, so a point that leaves
    /// the edge it sits on pulls the boundary inward and leaves undefined
    /// color behind it. Points on an edge may slide **along** that edge but not
    /// off it; corners, being on two edges, are pinned outright.
    private static func freedom(row: Int, column: Int) -> SIMD2<Double> {
        let last = gridSize - 1
        let onSideEdge = column == 0 || column == last
        let onTopOrBottom = row == 0 || row == last
        return SIMD2(onSideEdge ? 0 : 1, onTopOrBottom ? 0 : 1)
    }

    /// Per-point, per-axis frequency and phase, derived from the index by
    /// golden-ratio stepping rather than stored in a table: it spreads 50
    /// values evenly with no two close together, and it scales with `gridSize`.
    private static func frequency(_ index: Int, _ axis: Int) -> Double {
        0.16 + fraction(Double(index * 2 + axis) * 0.6180339887) * 0.22
    }

    private static func phase(_ index: Int, _ axis: Int) -> Double {
        fraction(Double(index * 2 + axis + 1) * 0.7548776662) * 2 * .pi
    }

    private static func fraction(_ value: Double) -> Double {
        value - value.rounded(.down)
    }

    /// One axis of travel: a base wave plus a detuned second harmonic,
    /// weighted so the total stays within +/-1 and therefore within amplitude.
    private static func wander(_ elapsed: Double, _ index: Int, axis: Int,
                               wave: (Double) -> Double) -> Double {
        let frequency = frequency(index, axis)
        let phase = phase(index, axis)
        let base = wave(elapsed * frequency + phase)
        let harmonic = wave(elapsed * frequency * harmonicRatio + phase * 2)
        return base * (1 - harmonicWeight) + harmonic * harmonicWeight
    }
}
