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
                .lineLimit(1)
        }
        .padding(.vertical, Metrics.Grid.zoneRowPadding)
        .padding(.leading, Metrics.Grid.zoneRowLeadingPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
