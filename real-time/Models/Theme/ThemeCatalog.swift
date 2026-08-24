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

    /// A three-stop palette. How the stops are spread across the mesh, and
    /// how they drift, is `MeshColors`' business.
    private static func mesh(_ id: String, _ name: String,
                             _ first: UInt32, _ second: UInt32, _ third: UInt32) -> Theme {
        Theme(id: id, name: name,
              background: .mesh([Color(hex: first), Color(hex: second), Color(hex: third)]))
    }

    /// A four-stop palette.
    private static func mesh(_ id: String, _ name: String,
                             _ first: UInt32, _ second: UInt32,
                             _ third: UInt32, _ fourth: UInt32) -> Theme {
        Theme(id: id, name: name,
              background: .mesh([Color(hex: first), Color(hex: second),
                                 Color(hex: third), Color(hex: fourth)]))
    }

    // MARK: - Categories

    /// The only achromatic themes, and the only solid (non-animating) ones.
    /// Kept apart from the palettes because they are a different kind of
    /// choice: not a mood, but the absence of one.
    static let basics = ThemeCategory(
        id: "basics",
        name: "Basics",
        themes: [
            Theme(id: "midnight", name: "Midnight", background: .solid(.black)),
            Theme(id: "paper", name: "Paper", background: .solid(Color(hex: 0xF0F0F0))),
        ]
    )

    private static let night = ThemeCategory(
        id: "night",
        name: "Night",
        themes: [
            mesh("starry-night", "Starry night", 0x0E1220, 0x171E38, 0x262F52),
            mesh("night-aurora", "Aurora", 0x0B1520, 0x14524F, 0x58C9A0),
            mesh("street-lights", "Street lights", 0x141220, 0x382E48, 0xD98A45),
            mesh("forest", "Forest", 0x0E1512, 0x17302B, 0x2C5449),
            mesh("moonlit-lake", "Moonlit lake", 0x101A2C, 0x2C4A6E, 0x8FA8BE),

            // Vivid: the same mood at high chroma. Ordered after the muted
            // palettes so each section reads quiet to loud.
            mesh("neon-city", "Neon city", 0x0A0A14, 0xD42A8C, 0xFF3D9E),
            mesh("synthwave-horizon", "Synthwave horizon",
                 0x12061F, 0x8B1FA8, 0xFF5FA2, 0xFFB35C),
            mesh("blacklight-forest", "Blacklight forest", 0x060E0C, 0x1FBF6E, 0x6BFF9E),
            mesh("deep-sea", "Deep sea", 0x04101F, 0x0F6ED9, 0x35E5FF),
        ]
    )

    private static let happiness = ThemeCategory(
        id: "happiness",
        name: "Happiness",
        themes: [
            mesh("rainbow", "Rainbow", 0x2A2340, 0xC25C63, 0xD9B45C, 0x4FA89E),
            mesh("meadow", "Meadow", 0x1E2A1C, 0x6E8C4A, 0xD6C87A),
            mesh("sunflower", "Sunflower", 0x2A2412, 0xB8891C, 0xE0CE72),
            mesh("golden-hour", "Golden hour", 0x2C1E2A, 0xC4795C, 0xE8C49A),

            // Vivid
            mesh("electric-rainbow", "Electric rainbow",
                 0x1A0A2E, 0xFF2E93, 0xFFC93D, 0x2EE8B0),
            mesh("hot-sunshine", "Hot sunshine", 0x2E1206, 0xFF6B1F, 0xFFD84D),
            mesh("neon-meadow", "Neon meadow", 0x0E2010, 0x4DE83D, 0xE8FF5C),
            mesh("candy-sunset", "Candy sunset", 0x2A0E2A, 0xFF4D8F, 0xFFA85C),
            mesh("confetti-burst", "Confetti burst",
                 0x160C2E, 0xFF3D6E, 0x3DD9FF, 0xFFE03D),
        ]
    )

    /// Calm resists neon by definition, so its vivid palettes are a glow
    /// rather than a blast: single-hue, high chroma, deliberately little
    /// variety.
    private static let calm = ThemeCategory(
        id: "calm",
        name: "Calm",
        themes: [
            mesh("zen-garden", "Zen garden", 0x1E1C18, 0x4A4436, 0x9C9078),
            mesh("fog", "Fog", 0x1C2124, 0x454F55, 0x8A979E),
            mesh("snow", "Snow", 0x20262E, 0x4E5D6B, 0xC3CFD8),

            // Vivid
            mesh("ice-glow", "Ice glow", 0x0A1620, 0x2E9ED9, 0x7FE8FF),
            mesh("neon-mist", "Neon mist", 0x12141F, 0x5C6BD9, 0xA8B5FF),
            mesh("menthol-water", "Menthol water", 0x08201C, 0x1FC4A8, 0x6BFFE0),
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

            // Vivid
            mesh("electric-lightning", "Electric lightning", 0x0A0A1F, 0x6B3DFF, 0xE0FF3D),
            mesh("lava-surge", "Lava surge", 0x1A0606, 0xE02414, 0xFF8A1F),
            mesh("plasma-waves", "Plasma waves", 0x04161F, 0x0F9ED9, 0x3DFFE0),
            mesh("voltage", "Voltage", 0x0E0A1F, 0xB82EFF, 0xFF2E6B),
            mesh("redline", "Redline", 0x1A0410, 0xFF1F5C, 0xFF9E3D),
        ]
    )

    private static let allCategories: [ThemeCategory] = [
        basics, night, happiness, calm, storm,
    ]
}
