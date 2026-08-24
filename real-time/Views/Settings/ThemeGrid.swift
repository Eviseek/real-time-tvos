import SwiftUI

/// Full-screen theme picker.
struct ThemeGrid: View {
    @Environment(\.settings) private var settings
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: Metrics.Grid.themeColumnMinimum),
                                   spacing: Metrics.Grid.themeSpacing)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Metrics.Grid.themeSpacing) {
                ForEach(settings.availableThemes) { theme in
                    Button { select(theme) } label: {
                        ThemeTile(theme: theme, isSelected: theme.id == settings.themeID)
                    }
                    // Apple's standard tvOS tile treatment. A focus appearance
                    // is not optional on a platform navigated by focus.
                    .buttonStyle(.card)
                }
            }
            .padding(Metrics.Grid.padding)
        }
    }

    private func select(_ theme: Theme) {
        settings.themeID = theme.id
        dismiss()
    }
}
