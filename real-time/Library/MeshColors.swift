import SwiftUI

/// Spreads a palette's stops across the mesh's control points.
///
/// Deliberately time-invariant. Drifting the palette through the points makes
/// each point's colour blend continuously from one stop to the next, which
/// reads as colours fading out and others fading in — and at any instant some
/// stop is not on screen at all. Welding each point to one stop keeps every
/// colour present for good; what changes is where the points are, and so how
/// much of the screen each colour covers.
enum MeshColors {
    static func colors(_ stops: [Color]) -> [Color] {
        let ring = ring(of: stops)
        return (0..<MeshPoints.pointCount).map { index in
            let row = index / MeshPoints.gridSize
            let column = index % MeshPoints.gridSize
            // Banded along the diagonal, so colour runs corner to corner
            // rather than in rows or columns, which would read as a wipe.
            // Integer positions, so every point gets an exact stop rather than
            // a blend of two.
            return ring[(row + column) % ring.count]
        }
    }

    /// Mirrors the palette so neighbouring bands are always adjacent stops:
    /// three stops become a-b-c-b. Without it the diagonal would wrap the last
    /// stop straight back onto the first, which is the harsh jump a
    /// hand-ordered palette exists to avoid.
    ///
    /// A 3x3's diagonal spans five bands, so every stop lands on at least one
    /// point: `a b c b a` for three stops, `a b c d c` for four.
    private static func ring(of stops: [Color]) -> [Color] {
        guard stops.count > 2 else { return stops }
        return stops + stops.dropFirst().dropLast().reversed()
    }
}
