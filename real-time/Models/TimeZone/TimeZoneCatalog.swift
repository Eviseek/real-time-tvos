import Foundation

/// Every zone the system knows about.
/// `nonisolated` because the project defaults actor isolation to `MainActor`:
/// without it this pure value type's initializer is main-actor-bound and
/// cannot be used as a plain function reference.
nonisolated struct TimeZoneCatalog: TimeZoneProviding {
    static let shared = TimeZoneCatalog()

    var all: [TimeZoneOption] { Self.sorted }

    func options(matching query: String) -> [TimeZoneOption] {
        guard !query.isEmpty else { return all }
        return all.filter { $0.display.localizedCaseInsensitiveContains(query) }
    }

    /// ~600 entries, built once and sorted by **city** rather than raw
    /// identifier, so "Prague" is findable without knowing it lives under
    /// "Europe/".
    private static let sorted: [TimeZoneOption] = TimeZone.knownTimeZoneIdentifiers
        .map(TimeZoneOption.init(identifier:))
        .sorted { $0.city.localizedCaseInsensitiveCompare($1.city) == .orderedAscending }
}
