import SwiftUI

/// How the user wants the clock digits drawn.
///
/// Entirely a preference: a theme supplies a background and nothing else, so
/// the same palette can carry white digits in a bright room and glass ones at
/// night. Three options rather than four — there is no "match theme", because
/// a theme no longer has a digit colour to match.
enum ClockColor: String, CaseIterable, Identifiable, Sendable {
    case white
    case black
    /// Liquid glass with nothing behind it, so the background shows through
    /// the glyphs. Needs a dark palette to read.
    case glass

    var id: String { rawValue }

    var name: String {
        switch self {
        case .white: "White"
        case .black: "Black"
        case .glass: "Liquid glass"
        }
    }

    /// Colour for text that is not the time itself. Glass has no colour of its
    /// own to lend, so the label falls back to white.
    var secondaryColor: Color {
        switch self {
        case .white, .glass: .white
        case .black: .black
        }
    }
}
