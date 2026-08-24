import SwiftUI

/// Assigns colours to the mesh's control points, and drifts them across the
/// grid over time.
///
/// Point motion alone cannot make a colour travel. The mesh boundary is pinned
/// so the gradient fills the screen, which means every point stays near where
/// it started — and a colour welded to a point can only rock back and forth in
/// its own corner. Moving the *colours* through the grid is what reads as a
/// lava lamp.
enum MeshColors {
    /// Seconds for a colour to travel one full lap of the palette. Slow: a lap
    /// is the whole journey from one end of the palette and back, and the
    /// point is that you notice it has moved, not that you watch it move.
    static let lapDuration: Double = 26

    static func colors(_ stops: [Color], at time: Double) -> [Color] {
        let ring = ring(of: stops)
        let drift = time / lapDuration * Double(ring.count)
        return (0..<MeshPoints.pointCount).map { index in
            let row = index / MeshPoints.gridSize
            let column = index % MeshPoints.gridSize
            // Banded along the diagonal, so colour sweeps corner to corner
            // rather than in rows or columns, which would read as a wipe.
            return sample(ring, at: Double(row + column) + drift)
        }
    }

    /// Mirrors the palette so it loops without a seam: three stops become
    /// a-b-c-b. Cycling a-b-c directly would butt the last stop against the
    /// first once per lap, which is the harsh jump a hand-ordered palette
    /// exists to avoid.
    private static func ring(of stops: [Color]) -> [Color] {
        guard stops.count > 2 else { return stops }
        return stops + stops.dropFirst().dropLast().reversed()
    }

    /// Reads the ring at a fractional position, blending the two stops it
    /// falls between, so the drift is continuous rather than stepped.
    private static func sample(_ ring: [Color], at position: Double) -> Color {
        let count = Double(ring.count)
        let wrapped = position.truncatingRemainder(dividingBy: count)
        let base = wrapped < 0 ? wrapped + count : wrapped
        let low = Int(base)
        return ring[low % ring.count]
            .mix(with: ring[(low + 1) % ring.count], by: base - Double(low))
    }
}
