import SwiftUI

/// The shipped set of themes, grouped into categories.
///
/// Defined in code rather than data because each palette is a design decision,
/// not user content. The hex literals below are the palette itself: each one
/// sits on the line that names the theme it belongs to, so it documents itself
/// in a way a separate constant could not.
nonisolated struct ThemeCatalog: ThemeProviding {
    static let shared = ThemeCatalog()

    var categories: [ThemeCategory] { Self.allCategories }

    /// Midnight: white on black. The safe default — readable on every panel,
    /// and the lowest power draw on an OLED left on for hours.
    var defaultTheme: Theme { Self.basics.themes[0] }

    func theme(id: String) -> Theme {
        Self.allCategories
            .lazy
            .flatMap(\.themes)
            .first { $0.id == id } ?? defaultTheme
    }

    // MARK: - Construction

    /// Expands three stops into the 9 colors a 3x3 mesh needs, rotating them
    /// so no two adjacent control points share a color and the gradient reads
    /// as continuous rather than banded.
    private static func mesh(_ id: String, _ name: String,
                             _ first: UInt32, _ second: UInt32, _ third: UInt32,
                             foreground: ForegroundStyle = .solid(.white)) -> Theme {
        let a = Color(hex: first), b = Color(hex: second), c = Color(hex: third)
        return Theme(id: id, name: name,
                     background: .mesh([a, b, c,
                                        b, c, a,
                                        c, a, b]),
                     foreground: foreground)
    }

    /// Four stops, laid out along the diagonal instead of rotated.
    ///
    /// Rotation would put the first and last stop side by side, which is
    /// exactly the harsh spectral jump a four-stop palette exists to avoid.
    /// Running them corner to corner keeps the sequence in order, at the cost
    /// of repeating the last stop to fill the ninth point.
    private static func mesh(_ id: String, _ name: String,
                             _ first: UInt32, _ second: UInt32,
                             _ third: UInt32, _ fourth: UInt32,
                             foreground: ForegroundStyle = .solid(.white)) -> Theme {
        let a = Color(hex: first), b = Color(hex: second)
        let c = Color(hex: third), d = Color(hex: fourth)
        return Theme(id: id, name: name,
                     background: .mesh([a, b, c,
                                        b, c, d,
                                        c, d, d]),
                     foreground: foreground)
    }

    // MARK: - Categories

    /// The only achromatic themes, and the only solid (non-animating) ones.
    /// Kept apart from the palettes because they are a different kind of
    /// choice: not a mood, but the absence of one.
    static let basics = ThemeCategory(
        id: "basics",
        name: "Basics",
        themes: [
            Theme(id: "midnight", name: "Midnight",
                  background: .solid(.black), foreground: .solid(.white)),
            Theme(id: "paper", name: "Paper",
                  background: .solid(Color(hex: 0xF0F0F0)),
                  foreground: .solid(Color(hex: 0x141414))),
        ]
    )

    private static let night = ThemeCategory(
        id: "night",
        name: "Night",
        themes: [
            mesh("starry-night", "Starry night", 0x0E1220, 0x171E38, 0x262F52),
            mesh("night-aurora", "Aurora", 0x0B1520, 0x14524F, 0x58C9A0,
                 foreground: .glass),
            mesh("street-lights", "Street lights", 0x141220, 0x382E48, 0xD98A45),
            mesh("forest", "Forest", 0x0E1512, 0x17302B, 0x2C5449),
            mesh("moonlit-lake", "Moonlit lake", 0x101A2C, 0x2C4A6E, 0x8FA8BE),
        ]
    )

    private static let happiness = ThemeCategory(
        id: "happiness",
        name: "Happiness",
        themes: [
            // Solid, not glass: this palette runs light through its upper
            // half, and glass glyphs over a light field are illegible.
            mesh("rainbow", "Rainbow", 0x2A2340, 0xC25C63, 0xD9B45C, 0x4FA89E),
            mesh("sunshine", "Sunshine", 0x3A2A1E, 0xC98A32, 0xE8CB7A),
            mesh("meadow", "Meadow", 0x1E2A1C, 0x6E8C4A, 0xD6C87A),
            mesh("sunflower", "Sunflower", 0x2A2412, 0xB8891C, 0xE0CE72),
            mesh("golden-hour", "Golden hour", 0x2C1E2A, 0xC4795C, 0xE8C49A),
        ]
    )

    private static let calm = ThemeCategory(
        id: "calm",
        name: "Calm",
        themes: [
            mesh("misty-dawn", "Misty dawn", 0x182028, 0x3C5260, 0x8AA2AE),
            mesh("zen-garden", "Zen garden", 0x1E1C18, 0x4A4436, 0x9C9078),
            mesh("fog", "Fog", 0x1C2124, 0x454F55, 0x8A979E),
            mesh("snow", "Snow", 0x20262E, 0x4E5D6B, 0xC3CFD8),
            mesh("rain-on-window", "Rain on window", 0x161E24, 0x3A4C58, 0x7C8F9C),
        ]
    )

    private static let storm = ThemeCategory(
        id: "storm",
        name: "Storm",
        themes: [
            mesh("lightning", "Lightning", 0x12121F, 0x3A3A55, 0xD6CE6E),
            mesh("waves", "Waves", 0x102A36, 0x226A70, 0x9EC4C8),
            mesh("volcanic", "Volcanic", 0x1C0F0E, 0x6E2214, 0xD9662A),
            mesh("sandstorm", "Sandstorm", 0x2E2418, 0x8E6640, 0xC9AC80),
            mesh("rapids", "Rapids", 0x12302C, 0x2C7064, 0xA8CFC6),
        ]
    )

    private static let allCategories: [ThemeCategory] = [
        basics, night, happiness, calm, storm,
    ]
}
