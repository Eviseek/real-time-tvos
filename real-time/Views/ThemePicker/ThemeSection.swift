import SwiftUI

/// One category in the theme list: its name, then its tiles.
///
/// No divider and no artwork of its own — the tiles below it are already the
/// illustration, and a rule between sections would only add a line to read.
struct ThemeSection: View {
    let category: ThemeCategory

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Grid.sectionTitleSpacing) {
            Text(category.name)
                .font(.system(size: Metrics.Grid.sectionTitleFontSize, weight: .semibold))
            ThemeTileGrid(themes: category.themes)
        }
    }
}
