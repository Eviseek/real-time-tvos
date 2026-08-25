import SwiftUI

/// The mesh at one instant, drawn oversized and shifted so its pinned boundary
/// sits outside the view.
struct SweptMesh: View {
    let stops: [Color]
    let moment: Double
    let view: CGSize

    var body: some View {
        let shift = MeshDrift.offset(at: moment)
        MeshGradient(width: MeshPoints.gridSize,
                     height: MeshPoints.gridSize,
                     points: MeshPoints.points(at: moment),
                     colors: MeshColors.colors(stops))
            .frame(width: view.width * MeshDrift.overscan,
                   height: view.height * MeshDrift.overscan)
            // `position` centres the oversized mesh and applies the sweep in
            // one step. A plain offset would leave it anchored to the
            // container's top-leading corner.
            .position(x: view.width * (0.5 + shift.x),
                      y: view.height * (0.5 + shift.y))
    }
}
