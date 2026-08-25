import SwiftUI

/// The time digits, drawn in whichever colour the viewer chose, followed by an
/// AM/PM marker whenever the 12-hour clock is showing.
struct ClockTimeText: View {
    let date: Date
    let color: ClockColor
    let timeZone: TimeZone
    let uses24HourTime: Bool

    private var text: String {
        date.formatted(ClockFormatter.timeFormat(for: timeZone, uses24Hour: uses24HourTime))
    }

    private var dayPeriod: String? {
        ClockFormatter.dayPeriod(for: date, in: timeZone, uses24Hour: uses24HourTime)
    }

    var body: some View {
        // Aligned on the first baseline, so the smaller marker stands on the
        // line the digits stand on rather than centring against their height.
        HStack(alignment: .firstTextBaseline, spacing: Metrics.Clock.dayPeriodSpacing) {
            styled(text, size: Metrics.Clock.timeFontSize)
            if let dayPeriod {
                styled(dayPeriod, size: Metrics.Clock.dayPeriodFontSize)
            }
        }
    }

    /// One switch serving both the digits and the marker, so the marker cannot
    /// be drawn as something the digits beside it are not.
    @ViewBuilder private func styled(_ text: String, size: CGFloat) -> some View {
        switch color {
        case .white:
            solid(text, size: size, tint: .white)
        case .black:
            solid(text, size: size, tint: .black)
        case .glass:
            GlassClockText(text: text, fontSize: size)
        }
    }

    private func solid(_ text: String, size: CGFloat, tint: Color) -> some View {
        Text(text)
            .clockDigitFont(size: size)
            .foregroundStyle(tint)
    }
}
