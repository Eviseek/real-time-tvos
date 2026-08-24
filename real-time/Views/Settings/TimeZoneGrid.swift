import SwiftUI

/// The selectable rows. Split from `TimeZonePicker` so the picker holds only
/// the search state and this holds only the selection.
struct TimeZoneGrid: View {
    let options: [TimeZoneOption]

    @Environment(\.settings) private var settings
    @Environment(\.dismiss) private var dismiss

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
        dismiss()
    }
}
