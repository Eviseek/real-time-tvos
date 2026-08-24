import SwiftUI

/// The shipped set of themes, defined in code rather than data because each
/// pairing is a design decision, not user content.
struct ThemeCatalog: ThemeProviding {
    static let shared = ThemeCatalog()

    var all: [Theme] { Self.themes }

    /// Midnight: white on black. The safe default — readable on every panel,
    /// and the lowest power draw on an OLED display left on for hours.
    var defaultTheme: Theme { Self.themes[0] }

    func theme(id: String) -> Theme {
        all.first { $0.id == id } ?? defaultTheme
    }

    // MARK: - Palette

    /// Named palette entries. The component values are the palette itself —
    /// naming them keeps every raw number out of the theme list below.
    private enum Palette {
        /// Near-black paper ink, not pure black: pure black on a light field
        /// reads as harsh at TV scale.
        static let ink = Color(white: 0.08)
        /// Warm off-white, dimmed from pure white to cut glare in a dark room.
        static let paper = Color(white: 0.94)

        /// Ember — banked coals through to flame.
        static let emberDeep = Color(red: 0.35, green: 0.05, blue: 0.02)
        static let emberMid = Color(red: 0.85, green: 0.28, blue: 0.05)
        static let emberBright = Color(red: 0.98, green: 0.62, blue: 0.15)

        /// Ocean — deep water through to shallows.
        static let oceanDeep = Color(red: 0.02, green: 0.09, blue: 0.28)
        static let oceanMid = Color(red: 0.05, green: 0.35, blue: 0.62)
        static let oceanBright = Color(red: 0.20, green: 0.72, blue: 0.80)

        /// Aurora — night sky, green curtain, violet edge.
        static let auroraDeep = Color(red: 0.04, green: 0.16, blue: 0.20)
        static let auroraMid = Color(red: 0.10, green: 0.62, blue: 0.45)
        static let auroraBright = Color(red: 0.45, green: 0.25, blue: 0.72)

        /// Dusk — the last of the light going violet.
        static let duskDeep = Color(red: 0.14, green: 0.05, blue: 0.28)
        static let duskMid = Color(red: 0.55, green: 0.15, blue: 0.45)
        static let duskBright = Color(red: 0.95, green: 0.45, blue: 0.35)
    }

    /// Expands three colors into the 9 a 3x3 mesh needs, rotating them so no
    /// two adjacent control points share a color and the gradient reads as
    /// continuous rather than banded.
    private static func mesh(_ first: Color, _ second: Color, _ third: Color) -> BackgroundStyle {
        .mesh([first, second, third,
               second, third, first,
               third, first, second])
    }

    private static let themes: [Theme] = [
        Theme(id: "midnight",
              name: "Midnight",
              background: .solid(.black),
              foreground: .solid(.white)),

        Theme(id: "paper",
              name: "Paper",
              background: .solid(Palette.paper),
              foreground: .solid(Palette.ink)),

        Theme(id: "ember",
              name: "Ember",
              background: mesh(Palette.emberDeep, Palette.emberMid, Palette.emberBright),
              foreground: .solid(.white)),

        Theme(id: "ocean",
              name: "Ocean",
              background: mesh(Palette.oceanDeep, Palette.oceanMid, Palette.oceanBright),
              foreground: .solid(.white)),

        Theme(id: "aurora",
              name: "Aurora",
              background: mesh(Palette.auroraDeep, Palette.auroraMid, Palette.auroraBright),
              foreground: .glass),

        Theme(id: "dusk",
              name: "Dusk",
              background: mesh(Palette.duskDeep, Palette.duskMid, Palette.duskBright),
              foreground: .glass),
    ]
}
