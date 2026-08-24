import SwiftUI

/// Full-screen, searchable picker over every zone the system knows.
struct TimeZonePicker: View {
    @State private var query = ""

    private let zones: any TimeZoneProviding = TimeZoneCatalog.shared

    private var results: [TimeZoneOption] { zones.options(matching: query) }

    var body: some View {
        ScrollView {
            TimeZoneGrid(options: results)
        }
        .searchable(text: $query, prompt: "Search cities")
        .overlay {
            if results.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
    }
}
