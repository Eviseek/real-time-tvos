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
        }
        .font(.callout)
    }
}
