import Foundation

/// Turns a `Date` into the strings the clock displays.
///
/// Separate from the views so the formatting rules — zero-padded, Latin
/// digits, an explicit clock — are stated once and are testable without
/// rendering.
enum ClockFormatter {
    /// The hour at which the day period flips from AM to PM.
    private static let noonHour = 12

    /// Verbatim rather than `DateFormatter`: it is a value type so it is cheap
    /// to build per render, and it is explicitly zero-padded so no locale can
    /// override the chosen clock or substitute non-Latin digits.
    ///
    /// The 12-hour form carries no day-period marker: the clock draws that
    /// separately, at its own size, so it cannot be part of this string.
    static func timeFormat(for timeZone: TimeZone, uses24Hour: Bool) -> Date.VerbatimFormatStyle {
        if uses24Hour {
            .verbatim(
                "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)",
                timeZone: timeZone,
                calendar: .current
            )
        } else {
            .verbatim(
                "\(hour: .twoDigits(clock: .twelveHour, hourCycle: .oneBased)):\(minute: .twoDigits):\(second: .twoDigits)",
                timeZone: timeZone,
                calendar: .current
            )
        }
    }

    /// `AM` or `PM` beside a 12-hour time, and `nil` for a 24-hour one, so a
    /// caller can ask unconditionally and draw whatever comes back.
    ///
    /// Derived from the hour rather than from a locale's day-period symbol,
    /// for the same reason the format above is verbatim: the marker is a fixed
    /// part of this design, not something a region may rewrite.
    static func dayPeriod(for date: Date, in timeZone: TimeZone, uses24Hour: Bool) -> String? {
        guard !uses24Hour else {
            return nil
        }
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.component(.hour, from: date) < noonHour ? "AM" : "PM"
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
