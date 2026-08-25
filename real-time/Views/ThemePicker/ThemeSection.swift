import SwiftUI

/// One category in the theme list: its name, then its tiles.
///
/// No divider and no artwork of its own — the tiles below it are already the
/// illustration, and a rule between sections would only add a line to read.
struct ThemeSection: View {
    let category: ThemeCategory

    @Environment(\.settings) private var settings
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: Metrics.Grid.themeColumnMinimum),
                                   spacing: Metrics.Grid.themeSpacing)]

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Grid.sectionTitleSpacing) {
            title
            content
        }
    }
    
    private var title: some View {
        Text(category.name)
            .font(.system(size: Metrics.Grid.sectionTitleFontSize, weight: .semibold))
    }
    
    private var content: some View {
        LazyVGrid(columns: columns, spacing: Metrics.Grid.themeSpacing) {
            ForEach(category.themes) { theme in
                Button {
                    settings.themeID = theme.id
                    dismiss()
                } label: {
                    ThemeTile(theme: theme,
                              color: settings.clockColor,
                              name: theme.name,
                              isSelected: theme.id == settings.themeID)
                }
                .buttonStyle(.card)
            }
        }
    }
}
