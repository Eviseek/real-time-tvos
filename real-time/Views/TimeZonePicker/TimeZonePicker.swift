import SwiftUI

/// Full-screen, searchable picker over every zone the system knows.
struct TimeZonePicker: View {
    /// Read here, in the pushed screen itself, rather than down in the grid.
    /// `.searchable` replaces the `DismissAction` for the content it wraps, so
    /// a dismiss captured inside that content closes the search instead of
    /// popping this screen — which left the picker on screen after a selection.
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""

    private let zones: any TimeZoneProviding = TimeZoneCatalog.shared

    private var results: [TimeZoneOption] { zones.options(matching: query) }

    var body: some View {
        ScrollView {
            TimeZoneGrid(options: results) { dismiss() }
        }
        .searchable(text: $query, prompt: "Search cities")
        .overlay {
            if results.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
    }
}
