import SwiftUI

/// A sample time at tile scale, drawn in the chosen clock colour so a tile
/// cannot promise something the clock will not deliver.
struct ThemeTilePreviewText: View {
    let color: ClockColor

    /// A fixed sample rather than the live time: a tile is a swatch, and a
    /// grid of ticking clocks pulls the eye away from the choice being made.
    private static let sample = "12:04"

    var body: some View {
        switch color {
        case .white:
            solid(.white)
        case .black:
            solid(.black)
        case .glass:
            GlassClockText(text: Self.sample,
                            fontSize: Metrics.ThemeTile.previewFontSize)
        }
    }

    private func solid(_ color: Color) -> some View {
        Text(Self.sample)
            .clockDigitFont(size: Metrics.ThemeTile.previewFontSize)
            .foregroundStyle(color)
    }
}
