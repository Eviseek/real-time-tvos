import SwiftUI

/// One option in the theme list, drawn as a live miniature of itself: the
/// palette behind, a sample time in front, the name below.
///
/// Serves both axes of the list. A palette tile and a clock-colour tile are
/// the same picture — they differ only in which of the two the caption names,
/// and in which one the caller is holding fixed.
struct ThemeTile: View {
    let theme: Theme
    let color: ClockColor
    let name: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: Metrics.ThemeTile.captionSpacing) {
            ZStack {
                BackgroundView(style: theme.background, isAnimating: false)
                    .clipShape(.rect(cornerRadius: Metrics.ThemeTile.previewCornerRadius))
                ThemeTilePreviewText(color: color)
            }
            .frame(height: Metrics.ThemeTile.previewHeight)

            caption
                .padding(.bottom, Metrics.ThemeTile.captionBottomPadding)
        }
    }

    /// The name, with a checkmark when this is the active option.
    private var caption: some View {
        HStack(spacing: Metrics.ThemeTile.captionItemSpacing) {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
            }
            Text(name)
                .lineLimit(1)
                .minimumScaleFactor(Metrics.ThemeTile.captionMinimumScale)
                .padding(.horizontal, Metrics.Grid.zoneRowPadding)
        }
        .font(.callout)
    }
}
