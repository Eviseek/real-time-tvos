import SwiftUI

/// The selectable rows. Split from `TimeZonePicker` so the picker holds only
/// the search state and this holds only the selection.
///
/// Reports selection through `onSelected` rather than dismissing itself: this
/// sits inside `.searchable`'s content, where the ambient `DismissAction`
/// belongs to the search rather than to the screen.
struct TimeZoneGrid: View {
    let options: [TimeZoneOption]
    let onSelected: () -> Void

    @Environment(\.settings) private var settings

    private let columns = [GridItem(.adaptive(minimum: Metrics.Grid.zoneColumnMinimum),
                                   spacing: Metrics.Grid.zoneSpacing)]

    var body: some View {
        // Lazy so only visible cells are built: ~600 eager cells stall the
        // tvOS focus engine on first appearance.
        LazyVGrid(columns: columns, spacing: Metrics.Grid.zoneSpacing) {
            ForEach(options) { option in
                Button { select(option) } label: {
                    TimeZoneRow(option: option, isSelected: option.id == settings.timeZoneID)
                }
                .buttonStyle(.card)
            }
        }
        .padding(Metrics.Grid.padding)
    }

    private func select(_ option: TimeZoneOption) {
        settings.timeZoneID = option.id
        onSelected()
    }
}
