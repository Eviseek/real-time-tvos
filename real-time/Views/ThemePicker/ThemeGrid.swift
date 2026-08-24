import SwiftUI

/// Full-screen theme picker: clock colour first, then one titled section per
/// category. Sections are always open — there is nothing to collapse.
struct ThemeGrid: View {
    @Environment(\.settings) private var settings

    var body: some View {
        ScrollView {
            // Lazy so only the sections near the viewport build their tiles.
            // Twenty-two live previews built eagerly would stall the focus
            // engine on first appearance.
            LazyVStack(alignment: .leading, spacing: Metrics.Grid.sectionSpacing) {
                ClockColorSection()
                ForEach(settings.themeCategories) { category in
                    ThemeSection(category: category)
                }
            }
            .padding(Metrics.Grid.padding)
        }
    }
}
