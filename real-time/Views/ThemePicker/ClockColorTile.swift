import SwiftUI

/// One clock-colour option, previewed over the theme that is currently active
/// so the choice is judged in the context it will be used.
///
/// `isAnimating: false` because a row of four live 30fps previews of the same
/// gradient costs more than the screen they are previewing.
struct ClockColorTile: View {
    let option: ClockColor
    let theme: Theme
    let isSelected: Bool

    var body: some View {
        VStack(spacing: Metrics.ThemeTile.captionSpacing) {
            ZStack {
                BackgroundView(style: theme.background, isAnimating: false)
                    .clipShape(.rect(cornerRadius: Metrics.ThemeTile.previewCornerRadius))
                ThemeTilePreviewText(style: option.style(for: theme))
            }
            .frame(height: Metrics.ThemeTile.previewHeight)

            ThemeTileCaption(name: option.name, isSelected: isSelected)
                .padding(.bottom, Metrics.ThemeTile.captionBottomPadding)
        }
    }
}
