import Foundation

/// Control-point geometry for the 3x3 mesh background.
///
/// Pure math with no SwiftUI dependency, so it lives in `Library` and can be
/// reasoned about without rendering anything.
///
/// All phase arithmetic is deliberately `Double`, and only the final position
/// narrows to `Float`. `MeshGradient` wants `SIMD2<Float>`, but the time value
/// fed in is `timeIntervalSinceReferenceDate` — on the order of 8×10^8, where
/// a `Float`'s ulp is **64 seconds**. Converting the timestamp first freezes
/// the animation for a minute at a stretch and then jumps it.
enum MeshPoints {
    /// Both the width and the height of the control-point grid. A 3x3 mesh is
    /// the smallest that has a movable centre, and `MeshGradient` requires
    /// exactly `gridSize * gridSize` colors.
    static let gridSize = 3

    /// Row-major 3x3 grid, in unit-square coordinates.
    static let base: [SIMD2<Double>] = [
        SIMD2(0.0, 0.0), SIMD2(0.5, 0.0), SIMD2(1.0, 0.0),
        SIMD2(0.0, 0.5), SIMD2(0.5, 0.5), SIMD2(1.0, 0.5),
        SIMD2(0.0, 1.0), SIMD2(0.5, 1.0), SIMD2(1.0, 1.0),
    ]

    /// How far a point may drift from its base position, in unit-square terms.
    ///
    /// 0.08 is roughly 8% of the screen: enough that the gradient visibly
    /// moves, small enough that no color region crosses another and flips the
    /// mesh inside out. An edge point starts at 0.5, so this also keeps it
    /// clear of the corners it shares an edge with.
    static let defaultAmplitude: Double = 0.08

    /// Which axes each control point may travel on: `1` is free, `0` is pinned.
    ///
    /// Only the centre point is free in both. The mesh's outer boundary *is*
    /// the drawn region, so any point that leaves the edge it sits on pulls
    /// the boundary inward and leaves a wedge of undefined color at the screen
    /// border. Corners are pinned outright; edge midpoints may slide **along**
    /// their edge, which still animates the gradient without shrinking it.
    private static let freedom: [SIMD2<Double>] = [
        SIMD2(0, 0), SIMD2(1, 0), SIMD2(0, 0),
        SIMD2(0, 1), SIMD2(1, 1), SIMD2(0, 1),
        SIMD2(0, 0), SIMD2(1, 0), SIMD2(0, 0),
    ]

    /// Per-point horizontal frequency, in radians per second.
    ///
    /// Detuned deliberately: shared frequencies drift in lockstep and read as
    /// mechanical, while these values never visibly repeat. Entries for axes
    /// that `freedom` pins are unused and left at zero.
    private static let frequencyX: [Double] = [0, 0.31, 0, 0.23, 0.17, 0.29, 0, 0.19, 0]

    /// Per-point vertical frequency. Different from `frequencyX` so the centre
    /// point traces an open Lissajous path rather than a closed circle.
    private static let frequencyY: [Double] = [0, 0.24, 0, 0.33, 0.21, 0.27, 0, 0.35, 0]

    /// Per-point starting offset, in radians, so the points do not all begin
    /// their travel from the same place at launch.
    private static let phase: [Double] = [0, 0.00, 0, 1.70, 3.10, 4.60, 0, 2.40, 0]

    /// `MeshGradient` is defined over the unit square. A point outside it
    /// leaves part of the screen with no defined color.
    private static let domain: ClosedRange<Double> = 0...1

    static func points(at time: Double, amplitude: Double = defaultAmplitude) -> [SIMD2<Float>] {
        base.indices.map { index in
            let travel = SIMD2(
                sin(time * frequencyX[index] + phase[index]),
                cos(time * frequencyY[index] + phase[index])
            ) * amplitude * freedom[index]
            let moved = base[index] + travel
            return SIMD2(
                Float(moved.x.clamped(to: domain)),
                Float(moved.y.clamped(to: domain))
            )
        }
    }
}
