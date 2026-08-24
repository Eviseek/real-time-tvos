import SwiftUI

/// Renders the time so the background shows through the glyphs.
struct GlassClockText: View {
    let text: String
    let fontSize: CGFloat

    var body: some View {
        Text(text)
            .clockDigitFont(size: fontSize)
            .foregroundStyle(.white)
    }
}
