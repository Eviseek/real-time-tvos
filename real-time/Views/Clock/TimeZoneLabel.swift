import SwiftUI

/// The city name beneath the time, so a non-local zone is never ambiguous.
struct TimeZoneLabel: View {
    let timeZone: TimeZone
    let color: Color

    var body: some View {
        Text(ClockFormatter.cityName(for: timeZone))
            .font(.system(size: Metrics.Clock.zoneFontSize, weight: .medium, design: .rounded))
            .foregroundStyle(color.opacity(Metrics.Clock.zoneOpacity))
    }
}
