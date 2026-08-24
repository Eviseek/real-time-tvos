import CoreGraphics

/// Every layout value in the app: spacing, padding, corner radii, font sizes,
/// and frame dimensions.
///
/// One file so a designer can retune the whole app's rhythm in one place, and
/// so no view has to justify a bare number inline. Behavioural constants
/// (frame rates, timer durations, animation amplitudes) deliberately live
/// beside the code that uses them instead — this file is layout only.
///
/// Values are sized for a 10-foot viewing distance, which is why they look
/// large next to iOS equivalents.
enum Metrics {
    /// The clock itself: the largest type in the app.
    enum Clock {
        /// Height of the `HH:MM:ss` digits. Sized to fill roughly two thirds
        /// of a 1080p screen's width in a monospaced rounded face, which is
        /// the largest the string can be without risking a clip at 4:3.
        static let timeFontSize: CGFloat = 220

        /// The timezone city name. Roughly a fifth of the time's size — big
        /// enough to read across a room, small enough to stay secondary.
        static let zoneFontSize: CGFloat = 44

        /// Gap between the time and the city name. Generous, so the two read
        /// as separate lines of information rather than one block.
        static let stackSpacing: CGFloat = 28

        /// The city name is dimmed rather than shrunk further, so it recedes
        /// without becoming unreadable.
        static let zoneOpacity: Double = 0.75
    }

    /// One theme tile in the selection grid.
    enum ThemeTile {
        /// Preview height. A 16:9-ish slab at grid width, enough that a mesh
        /// gradient reads as a gradient rather than a smear.
        static let previewHeight: CGFloat = 160

        /// Matches the tvOS card focus treatment the tiles sit inside.
        static let previewCornerRadius: CGFloat = 18

        /// Sample time shown in a preview, at tile scale.
        static let previewFontSize: CGFloat = 46

        /// Gap between the preview and its caption.
        static let captionSpacing: CGFloat = 12

        /// Gap between the checkmark and the theme name.
        static let captionItemSpacing: CGFloat = 8
    }

    /// Grids inside the full-screen settings covers.
    enum Grid {
        /// Narrowest a theme tile may get before its preview stops being
        /// legible; the adaptive grid fits as many columns as this allows.
        static let themeColumnMinimum: CGFloat = 320

        /// Narrowest a timezone row may get before long names truncate.
        static let zoneColumnMinimum: CGFloat = 420

        /// Space between theme tiles, wide enough that the tvOS focus scale
        /// on one tile never overlaps its neighbour.
        static let themeSpacing: CGFloat = 40

        /// Timezone rows do not scale as much on focus, so they can sit closer.
        static let zoneSpacing: CGFloat = 28

        /// Inset from the screen edge. Large because tvOS overscan can clip
        /// anything nearer the bezel.
        static let padding: CGFloat = 60

        /// Vertical breathing room inside one timezone row.
        static let zoneRowPadding: CGFloat = 8
    }

    /// The auto-hiding settings bar.
    enum Overlay {
        /// Gap between the bar's buttons.
        static let buttonSpacing: CGFloat = 32

        /// Horizontal inset inside the capsule.
        static let horizontalPadding: CGFloat = 48

        /// Vertical inset inside the capsule.
        static let verticalPadding: CGFloat = 24

        /// Drop from the top of the screen, clear of tvOS overscan.
        static let topPadding: CGFloat = 40

        /// Gap between the animation button and its explanatory caption.
        static let captionSpacing: CGFloat = 4
    }
}
