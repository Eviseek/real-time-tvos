import SwiftUI

/// One theme in the selection grid, rendered as a live miniature of itself.
struct ThemeTile: View {
    let theme: Theme
    let isSelected: Bool

    var body: some View {
        VStack(spacing: Metrics.ThemeTile.captionSpacing) {
            ZStack {
                // Static preview: a grid of tiles each running its own 30fps
                // timeline would cost more than the screen it is previewing.
                BackgroundView(style: theme.background, isAnimating: false)
                    .clipShape(.rect(cornerRadius: Metrics.ThemeTile.previewCornerRadius))
                ThemeTilePreviewText(style: theme.foreground)
            }
            .frame(height: Metrics.ThemeTile.previewHeight)

            ThemeTileCaption(name: theme.name, isSelected: isSelected)
        }
    }
}
