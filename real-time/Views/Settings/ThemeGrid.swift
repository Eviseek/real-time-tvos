import SwiftUI

/// Full-screen theme picker: a category row above the tiles for that category.
struct ThemeGrid: View {
    @Environment(\.settings) private var settings

    /// Nil until the user picks one. Until then the picker opens on whichever
    /// category holds the current theme, which is where they left off.
    @State private var pickedID: String?

    private var categories: [ThemeCategory] { settings.themeCategories }

    private var shown: ThemeCategory {
        categories.first { $0.id == pickedID }
            ?? categories.first { $0.contains(themeID: settings.themeID) }
            ?? categories[0]
    }

    var body: some View {
        VStack(spacing: Metrics.Grid.categorySpacing) {
            ThemeCategoryPicker(categories: categories, selectedID: shown.id) {
                pickedID = $0
            }
            ScrollView {
                ThemeTileGrid(themes: shown.themes)
            }
        }
        .padding(Metrics.Grid.padding)
    }
}
