import SwiftUI

/// A sample time at tile scale, drawn with the theme's real foreground so a
/// tile cannot drift from what it is previewing.
struct ThemeTilePreviewText: View {
    let style: ForegroundStyle

    /// A fixed sample rather than the live time: a tile is a swatch, and a
    /// grid of ticking clocks pulls the eye away from the choice being made.
    private static let sample = "12:04"

    var body: some View {
        switch style {
        case .solid(let color):
            Text(Self.sample)
                .clockDigitFont(size: Metrics.ThemeTile.previewFontSize)
                .foregroundStyle(color)
        case .glass:
            GlassClockText(text: Self.sample, fontSize: Metrics.ThemeTile.previewFontSize)
        }
    }
}
