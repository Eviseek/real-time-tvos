import SwiftUI

/// One category's segment in the theme picker, tinted with that category's
/// own stops so the segment previews the mood it stands for.
struct ThemeCategorySegment: View {
    let category: ThemeCategory
    let isSelected: Bool

    var body: some View {
        Text(category.name)
            .font(.system(size: Metrics.Grid.categoryFontSize, weight: .semibold))
            .padding(.horizontal, Metrics.Grid.categoryHorizontalPadding)
            .padding(.vertical, Metrics.Grid.categoryVerticalPadding)
            .background(gradient, in: .capsule)
            .overlay { if isSelected { border } }
            // Colour and a border are not enough on their own: this is what
            // tells VoiceOver which segment is the current one.
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var gradient: LinearGradient {
        LinearGradient(colors: category.segment,
                       startPoint: .leading,
                       endPoint: .trailing)
    }

    private var border: some View {
        Capsule().strokeBorder(.white, lineWidth: Metrics.Grid.categorySelectedBorderWidth)
    }
}
