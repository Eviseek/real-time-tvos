import SwiftUI

/// Full-screen, searchable picker over every zone the system knows.
struct TimeZonePicker: View {
    /// Read here, on the screen itself, and never from inside `body`'s
    /// `.searchable` content: that modifier replaces the `DismissAction` for
    /// everything it wraps, so a dismiss captured in there closes the search
    /// instead of popping this screen — which left the picker up after a
    /// selection. Members of this struct resolve outside it, so they pop.
    @Environment(\.dismiss) private var dismiss
    @Environment(\.settings) private var settings

    @State private var query = ""

    private let zones: any TimeZoneProviding = TimeZoneCatalog.shared

    private let columns = [GridItem(.adaptive(minimum: Metrics.Grid.zoneColumnMinimum),
                                   spacing: Metrics.Grid.zoneSpacing)]

    private var results: [TimeZoneOption] { zones.options(matching: query) }

    var body: some View {
        ScrollView {
            grid
        }
        .searchable(text: $query, prompt: "Search cities")
        .overlay {
            if results.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
    }

    private var grid: some View {
        // Lazy because timezones have ~600 cells
        LazyVGrid(columns: columns, spacing: Metrics.Grid.zoneSpacing) {
            ForEach(results) { option in
                Button {
                    settings.timeZoneID = option.id
                    dismiss()
                } label: {
                    TimeZoneRow(option: option, isSelected: option.id == settings.timeZoneID)
                }
                .buttonStyle(.card)
            }
        }
        .padding(Metrics.Grid.padding)
    }
}
