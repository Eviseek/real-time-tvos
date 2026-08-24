import SwiftUI

/// One clock-colour option, drawn on the tile's own neutral card rather than
/// over a theme.
///
/// No background here on purpose: this section is about the digits, and a
/// palette behind them makes four options look like four themes. A neutral
/// field also compares the four fairly, which a gradient does not — it can
/// flatter one and bury another.
///
/// `theme` is still needed even though it is not drawn: `.matchTheme` resolves
/// against it.
struct ClockColorTile: View {
    let option: ClockColor
    let theme: Theme
    let isSelected: Bool

    var body: some View {
        VStack(spacing: Metrics.ThemeTile.captionSpacing) {
            ThemeTilePreviewText(style: option.style(for: theme))
                // Without a background to fill it, the card would shrink to
                // the width of the digits. This holds the same footprint as a
                // theme tile so the two sections line up.
                .frame(maxWidth: .infinity,
                       minHeight: Metrics.ThemeTile.previewHeight,
                       maxHeight: Metrics.ThemeTile.previewHeight)

            ThemeTileCaption(name: option.name, isSelected: isSelected)
                .padding(.bottom, Metrics.ThemeTile.captionBottomPadding)
        }
    }
}
