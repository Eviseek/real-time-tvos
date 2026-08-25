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
            mesh("pine-frost", "Pine frost", 0x0B0909, 0x2E4540, 0x408175, 0xB5B9F0),

            // Vivid: the same mood at high chroma. Ordered after the muted
            // palettes so each section reads quiet to loud.
            mesh("neon-city", "Neon city", 0x0A0A14, 0xD42A8C, 0xFF3D9E),
            mesh("synthwave-horizon", "Synthwave horizon",
                 0x12061F, 0x8B1FA8, 0xFF5FA2, 0xFFB35C),
            mesh("blacklight-forest", "Blacklight forest", 0x060E0C, 0x1FBF6E, 0x6BFF9E),
            mesh("deep-sea", "Deep sea", 0x04101F, 0x0F6ED9, 0x35E5FF),
            mesh("blue-hour", "Blue hour", 0x091540, 0x1B2CC1, 0x7692FF, 0xABD2FA),
            mesh("nebula", "Nebula", 0x443199, 0x792CA2, 0xC13383, 0xE05454),
            mesh("orchid-night", "Orchid night", 0x15173D, 0x982598, 0xE491C9, 0xF1E9E9),
            mesh("ultraviolet", "Ultraviolet", 0x0E21A0, 0x4D2FB2, 0xB153D7, 0xF375C2),
            mesh("supernova", "Supernova", 0x1A05A2, 0x8F0177, 0xDE1A58, 0xF67D31),
            mesh("garnet", "Garnet", 0x111F35, 0x8A244B, 0xD02752, 0xF63049),
        ]
    )

    /// The palettes with no dark stop: every one of them lights the room
    /// rather than sitting behind the clock in it. They are a category and not
    /// a section because the choice they ask of the viewer is a different one
    /// — a light background wants a dark `ClockColor`, where every other
    /// palette here is legible under the white default.
    private static let daylight = ThemeCategory(
        id: "daylight",
        name: "Daylight",
        themes: [
            mesh("wisteria", "Wisteria", 0x9B8EC7, 0xBDA6CE, 0xB4D3D9, 0xF2EAE0),
            mesh("periwinkle", "Periwinkle", 0x6367FF, 0x8494FF, 0xC9BEFF, 0xFFDBFD),
            mesh("sorbet", "Sorbet", 0xB95E82, 0xF39F9F, 0xFFC29B, 0xFFECC0),
            mesh("bubblegum", "Bubblegum", 0xD6336C, 0xFF4081, 0xFFB6C1, 0xFFF5F8),
            mesh("mango", "Mango", 0xFA5C5C, 0xFD8A6B, 0xFEC288, 0xFBEF76),
            mesh("bonfire", "Bonfire", 0xE73F1E, 0xFB6C00, 0xF9B637, 0xFFDD9C),
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
            mesh("desert-dusk", "Desert dusk", 0x5E244E, 0xAA1C41, 0xE68457, 0xFFE8B4),
            mesh("kite-festival", "Kite festival", 0xFF5B5B, 0xF0FFC3, 0x9CCFFF, 0x685AFF),
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
            mesh("heather", "Heather", 0x403D88, 0x8B639B, 0xAF719D, 0xF8B2B2),
            mesh("sea-glass", "Sea glass", 0x4A4466, 0x6EADBC, 0x9FCBAD, 0xF1F7D4),
            mesh("olive-grove", "Olive grove", 0x41431B, 0xAEB784, 0xE3DBBB, 0xF8F3E1),

            // Vivid
            mesh("ice-glow", "Ice glow", 0x0A1620, 0x2E9ED9, 0x7FE8FF),
            mesh("neon-mist", "Neon mist", 0x12141F, 0x5C6BD9, 0xA8B5FF),
            mesh("menthol-water", "Menthol water", 0x08201C, 0x1FC4A8, 0x6BFFE0),
            mesh("jade", "Jade", 0x1F6F5F, 0x2FA084, 0x6FCF97, 0xEEEEEE),
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
            mesh("firewatch", "Firewatch", 0x003049, 0xD62828, 0xF77F00, 0xFCBF49),
            mesh("ember", "Ember", 0x5E0006, 0x9B0F06, 0xD53E0F, 0xEED9B9),
            mesh("live-wire", "Live wire", 0x362F4F, 0x5B23FF, 0x008BFF, 0xE4FF30),
        ]
    )

    private static let allCategories: [ThemeCategory] = [
        basics, night, daylight, happiness, calm, storm,
    ]
}
