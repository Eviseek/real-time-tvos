import SwiftUI

/// The `HH:MM:ss` digits, drawn in whichever colour the viewer chose.
struct ClockTimeText: View {
    let date: Date
    let color: ClockColor
    let timeZone: TimeZone

    private var text: String {
        date.formatted(ClockFormatter.timeFormat(for: timeZone))
    }

    var body: some View {
        switch color {
        case .white: solid(.white)
        case .black: solid(.black)
        case .glass: GlassClockText(text: text, fontSize: Metrics.Clock.timeFontSize)
        }
    }

    private func solid(_ color: Color) -> some View {
        Text(text)
            .clockDigitFont(size: Metrics.Clock.timeFontSize)
            .foregroundStyle(color)
    }
}
