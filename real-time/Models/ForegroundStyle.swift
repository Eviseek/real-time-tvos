import SwiftUI

/// How a theme renders the clock glyphs.
enum ForegroundStyle: Hashable, Sendable {
    case solid(Color)

    /// Liquid glass: the background shows through the glyphs.
    /// How that is achieved is private to `GlassClockText`.
    case glass

    /// The color for text that is not the time itself.
    ///
    /// Glass has no color of its own to borrow, so it falls back to white —
    /// every glass theme is dark by design, which is what makes glass legible.
    var secondaryColor: Color {
        if case .solid(let color) = self { return color }
        return .white
    }
}
