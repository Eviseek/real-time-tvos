import SwiftUI

/// Glass cut to the shape of the glyphs, so the background moves through them.
struct GlassGlyphLayer: View {
    let text: String
    let fontSize: CGFloat

    var body: some View {
        // `Text` is not a `Shape`, so `glassEffect` cannot take glyph geometry
        // directly. The hidden label supplies the layout, the overlay fills
        // that frame with glass, and the mask cuts it back to the glyphs.
        label
            .hidden()
            .overlay {
                GlassEffectContainer {
                    Rectangle().glassEffect(.clear, in: .rect)
                }
                .mask { label }
            }
    }

    private var label: some View {
        Text(text).clockDigitFont(size: fontSize)
    }
}
