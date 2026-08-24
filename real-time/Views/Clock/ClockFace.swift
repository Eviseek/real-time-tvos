import SwiftUI

struct ClockFace: View {
    let color: ClockColor
    let timeZone: TimeZone

    /// One second — the smallest unit the clock displays, so there is nothing
    /// to gain from ticking faster.
    private static let tickInterval: TimeInterval = 1

    var body: some View {
        // 1Hz, and deliberately NOT nested inside the 30fps background: nested
        // timelines would drag the digits up to the background's frame rate.
        TimelineView(.periodic(from: .now, by: Self.tickInterval)) { context in
            VStack(spacing: Metrics.Clock.stackSpacing) {
                ClockTimeText(date: context.date, color: color, timeZone: timeZone)
                TimeZoneLabel(timeZone: timeZone, color: color.secondaryColor)
            }
            // Spoken as one phrase: "10:23:45" read glyph by glyph is three
            // unrelated numbers.
            .accessibilityElement(children: .combine)
            .accessibilityLabel(ClockFormatter.spokenTime(context.date, in: timeZone))
        }
    }
}
