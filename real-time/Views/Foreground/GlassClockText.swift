import SwiftUI

/// Renders the time so the animated background shows through the glyphs.
struct GlassClockText: View {
    let text: String
    let fontSize: CGFloat

    /// Glass is close to unreadable for someone who has asked for less
    /// transparency, so this falls all the way back to opaque white.
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        if reduceTransparency {
            Text(text)
                .clockDigitFont(size: fontSize)
                .foregroundStyle(.white)
        } else {
            GlassGlyphLayer(text: text, fontSize: fontSize)
        }
    }
}
