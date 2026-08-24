import SwiftUI

/// A theme tile's name, with a checkmark when it is the active theme.
struct ThemeTileCaption: View {
    let name: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: Metrics.ThemeTile.captionItemSpacing) {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
            }
            Text(name)
                // A long name like "Deep-sea bioluminescence" would otherwise
                // wrap to two lines and make its tile taller than the others
                // in the row. Shrinking to fit keeps every row level.
                .lineLimit(1)
                .minimumScaleFactor(Metrics.ThemeTile.captionMinimumScale)
        }
        .font(.callout)
    }
}
