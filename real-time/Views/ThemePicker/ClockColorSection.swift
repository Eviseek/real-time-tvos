import SwiftUI

/// The first section of the theme list: how the digits are drawn, which is a
/// separate axis from which palette is behind them.
struct ClockColorSection: View {
    @Environment(\.settings) private var settings

    private let columns = [GridItem(.adaptive(minimum: Metrics.Grid.themeColumnMinimum),
                                   spacing: Metrics.Grid.themeSpacing)]

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Grid.sectionTitleSpacing) {
            title
            content
        }
    }
    
    private var title: some View {
        Text("Clock color")
            .font(.system(size: Metrics.Grid.sectionTitleFontSize, weight: .semibold))
    }
    
    private var content: some View {
        LazyVGrid(columns: columns, spacing: Metrics.Grid.themeSpacing) {
            ForEach(ClockColor.allCases) { option in
                // Deliberately does not dismiss: you pick a colour and
                // keep scrolling to try it against different palettes.
                Button {
                    settings.clockColor = option
                } label: {
                    // Previewed over the theme that is currently active,
                    // so the choice is judged where it will be used.
                    ThemeTile(theme: settings.theme,
                              color: option,
                              name: option.name,
                              isSelected: option == settings.clockColor)
                }
                .buttonStyle(.card)
            }
        }
    }
}
