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
            Spacer()
        }
        .padding(.vertical, Metrics.Grid.zoneRowPadding)
    }
}
