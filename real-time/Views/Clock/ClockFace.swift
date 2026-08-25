import SwiftUI

struct ClockFace: View {
    let color: ClockColor
    let timeZone: TimeZone

    private static let tickInterval: TimeInterval = 1

    var body: some View {
        // 1Hz, and deliberately NOT nested inside the 30fps background: nested
        // timelines would drag the digits up to the background's frame rate.
        TimelineView(.periodic(from: .now, by: Self.tickInterval)) { context in
            VStack(spacing: Metrics.Clock.stackSpacing) {
                ClockTimeText(date: context.date, color: color, timeZone: timeZone)
                zoneLabel
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(ClockFormatter.spokenTime(context.date, in: timeZone))
        }
    }

    /// The city name beneath the time, so a non-local zone is never ambiguous.
    private var zoneLabel: some View {
        Text(ClockFormatter.cityName(for: timeZone))
            .font(.system(size: Metrics.Clock.zoneFontSize, weight: .medium, design: .rounded))
            .foregroundStyle(color.secondaryColor.opacity(Metrics.Clock.zoneOpacity))
    }
}
