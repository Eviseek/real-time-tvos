/// Supplies the selectable timezones and filters them.
///
/// A protocol so a preview can inject a handful of zones instead of paying for
/// the full IANA list.
protocol TimeZoneProviding: Sendable {
    var all: [TimeZoneOption] { get }

    /// Zones matching `query`, or all of them when it is empty.
    func options(matching query: String) -> [TimeZoneOption]
}
