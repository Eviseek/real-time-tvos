import SwiftUI

/// Preferences that belong to no picker: the switches that change how the
/// clock reads rather than what it is made of.
struct SettingsScreen: View {
    @Environment(\.settings) private var settings

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Grid.sectionTitleSpacing) {
            title
            hourFormatToggle
        }
        .padding(Metrics.Grid.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var title: some View {
        Text("Settings")
            .font(.system(size: Metrics.Grid.sectionTitleFontSize, weight: .semibold))
    }

    /// Off means the 12-hour clock, which is what puts an AM/PM marker beside
    /// the digits. Written as a `Binding` by hand because the store arrives
    /// through the environment as an existential, which has no projected value.
    private var hourFormatToggle: some View {
        Toggle("24-hour time", isOn: Binding(
            get: { settings.uses24HourTime },
            set: { settings.uses24HourTime = $0 }
        ))
        .font(.system(size: Metrics.Settings.rowFontSize))
        .frame(maxWidth: Metrics.Settings.rowWidth)
    }
}
