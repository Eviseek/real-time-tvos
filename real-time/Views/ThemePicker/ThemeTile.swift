import SwiftUI

/// One theme in the selection grid, rendered as a live miniature of itself.
struct ThemeTile: View {
    let theme: Theme
    let isSelected: Bool

    @Environment(\.settings) private var settings

    var body: some View {
        VStack(spacing: Metrics.ThemeTile.captionSpacing) {
            ZStack {
                // Static preview: a grid of tiles each running its own 30fps
                // timeline would cost more than the screen it is previewing.
                BackgroundView(style: theme.background, isAnimating: false)
                    .clipShape(.rect(cornerRadius: Metrics.ThemeTile.previewCornerRadius))
                // Drawn with the chosen clock colour, not the theme's own, so
                // a tile cannot promise something the clock will not deliver.
                ThemeTilePreviewText(style: settings.clockColor.style(for: theme))
            }
            .frame(height: Metrics.ThemeTile.previewHeight)

            ThemeTileCaption(name: theme.name, isSelected: isSelected)
                .padding(.bottom, Metrics.ThemeTile.captionBottomPadding)
        }
    }
}
