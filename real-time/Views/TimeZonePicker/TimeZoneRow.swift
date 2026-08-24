import SwiftUI

/// One zone in the picker.
struct TimeZoneRow: View {
    let option: TimeZoneOption
    let isSelected: Bool

    var body: some View {
        HStack {
            if isSelected {
                Image(systemName: "checkmark")
            }
            Text(option.display)
                // Long identifiers must not reflow the grid's row heights.
                .lineLimit(1)
        }
        .padding(.vertical, Metrics.Grid.zoneRowPadding)
        .padding(.leading, Metrics.Grid.zoneRowLeadingPadding)
        // Fills the cell so the row stays left-aligned however short the name.
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
