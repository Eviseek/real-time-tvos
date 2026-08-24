import Foundation

/// Turns a `Date` into the strings the clock displays.
///
/// Separate from the views so the formatting rules — 24-hour, zero-padded,
/// Latin digits — are stated once and are testable without rendering.
enum ClockFormatter {
    /// Verbatim rather than `DateFormatter`: it is a value type so it is cheap
    /// to build per render, and it is explicitly 24-hour zero-based so no
    /// locale can substitute 12-hour behaviour or non-Latin digits.
    static func timeFormat(for timeZone: TimeZone) -> Date.VerbatimFormatStyle {
        .verbatim(
            "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)",
            timeZone: timeZone,
            calendar: .current
        )
    }

    /// The city portion of an IANA identifier: `Europe/Prague` becomes
    /// `Prague`. Underscores are separators in the identifier, not in the name.
    static func cityName(for timeZone: TimeZone) -> String {
        timeZone.identifier
            .split(separator: "/")
            .last
            .map { $0.replacingOccurrences(of: "_", with: " ") } ?? timeZone.identifier
    }

    /// A localized, spoken-language rendering for VoiceOver. The visual
    /// `HH:MM:ss` reads as three unrelated numbers when spoken aloud.
    static func spokenTime(_ date: Date, in timeZone: TimeZone) -> String {
        date.formatted(
            .dateTime.hour().minute().second().timeZone()
                .locale(.current)
        )
    }
}
