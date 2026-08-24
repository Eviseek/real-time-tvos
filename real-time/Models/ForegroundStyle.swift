import SwiftUI

/// How a theme renders the clock glyphs.
enum ForegroundStyle: Hashable, Sendable {
    case solid(Color)

    /// Liquid glass: the background shows through the glyphs.
    /// How that is achieved is private to `GlassClockText`.
    case glass
}
