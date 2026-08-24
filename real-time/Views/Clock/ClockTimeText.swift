import SwiftUI

/// The `HH:MM:ss` digits, rendered however the theme's foreground says.
struct ClockTimeText: View {
    let date: Date
    let style: ForegroundStyle
    let timeZone: TimeZone

    private var text: String {
        date.formatted(ClockFormatter.timeFormat(for: timeZone))
    }

    var body: some View {
        switch style {
        case .solid(let color):
            Text(text)
                .clockDigitFont(size: Metrics.Clock.timeFontSize)
                .foregroundStyle(color)
        case .glass:
            GlassClockText(text: text, fontSize: Metrics.Clock.timeFontSize)
        }
    }
}
