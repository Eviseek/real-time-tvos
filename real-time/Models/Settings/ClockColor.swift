import SwiftUI

/// How the user wants the clock digits drawn, independent of which theme is
/// active.
///
/// A preference rather than a property of the theme: the same palette suits a
/// white clock in a bright room and a glass one at night, and forcing that
/// choice into the catalog made it the designer's rather than the viewer's.
enum ClockColor: String, CaseIterable, Identifiable, Sendable {
    /// Whatever the theme itself specifies — the only option that can differ
    /// per theme, and the one that keeps `Paper` legible.
    case matchTheme
    case light
    case dark
    /// Liquid glass with nothing behind it, so the background shows through
    /// the glyphs. Needs a dark palette to read.
    case glass

    var id: String { rawValue }

    var name: String {
        switch self {
        case .matchTheme: "Match theme"
        case .light: "Light"
        case .dark: "Dark"
        case .glass: "Liquid glass"
        }
    }

    func style(for theme: Theme) -> ForegroundStyle {
        switch self {
        case .matchTheme: theme.foreground
        case .light: .solid(.white)
        case .dark: .solid(.black)
        case .glass: .glass
        }
    }
}
