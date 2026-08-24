import Foundation

/// One selectable zone, pre-split for display and search.
///
/// Built once rather than derived per keystroke: splitting ~600 identifiers on
/// every character typed is work the focus engine cannot afford.
/// `nonisolated` because the project defaults actor isolation to `MainActor`:
/// without it this pure value type's initializer is main-actor-bound and
/// cannot be used as a plain function reference.
nonisolated struct TimeZoneOption: Identifiable, Hashable, Sendable {
    /// The IANA identifier, e.g. `Europe/Prague`. Also what gets persisted.
    let id: String
    let city: String
    let region: String

    var display: String { region.isEmpty ? city : "\(city) · \(region)" }

    init(identifier: String) {
        self.id = identifier
        let parts = identifier.split(separator: "/")
        self.city = parts.last?.replacingOccurrences(of: "_", with: " ") ?? identifier
        // Single-component identifiers like "UTC" have no region to show.
        self.region = parts.count > 1
            ? parts[0].replacingOccurrences(of: "_", with: " ")
            : ""
    }
}
