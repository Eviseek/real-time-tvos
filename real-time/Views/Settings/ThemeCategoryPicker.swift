import SwiftUI

/// The row of category segments above the theme tiles.
struct ThemeCategoryPicker: View {
    let categories: [ThemeCategory]
    let selectedID: String
    let onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: Metrics.Grid.categorySpacing) {
            ForEach(categories) { category in
                Button {
                    onSelect(category.id)
                } label: {
                    ThemeCategorySegment(category: category,
                                         isSelected: category.id == selectedID)
                }
                // `.card` rather than `.plain`: on a platform navigated by
                // focus, a control with no focus appearance is unusable.
                .buttonStyle(.card)
            }
        }
    }
}
