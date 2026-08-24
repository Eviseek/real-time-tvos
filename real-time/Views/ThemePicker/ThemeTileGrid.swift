import SwiftUI

/// The tiles for one category.
struct ThemeTileGrid: View {
    let themes: [Theme]

    @Environment(\.settings) private var settings
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: Metrics.Grid.themeColumnMinimum),
                                   spacing: Metrics.Grid.themeSpacing)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Metrics.Grid.themeSpacing) {
            ForEach(themes) { theme in
                Button { select(theme) } label: {
                    ThemeTile(theme: theme, isSelected: theme.id == settings.themeID)
                }
                // Apple's standard tvOS tile treatment.
                .buttonStyle(.card)
            }
        }
    }

    private func select(_ theme: Theme) {
        settings.themeID = theme.id
        dismiss()
    }
}
