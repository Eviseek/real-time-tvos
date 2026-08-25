import SwiftUI

/// Glass cut to the exact shape of the glyphs, so the background moves
/// through the letterforms themselves rather than through a bounding box.
///
/// Ported from DanielCrompton123/LiquidGlassText: it turns the string into a
/// `Path` of glyph outlines (`TextHelper`) and hands that path straight to
/// `glassEffect`, which fills any `Shape` it is given.
struct LiquidGlassText: View {
    let text: String
    let fontSize: CGFloat

    var body: some View {
        let glyphs = TextHelper.path(for: text, font: FontHelper.clockFont(size: fontSize))
        Color.clear
            .glassEffect(.clear, in: glyphs.path)
            .frame(width: glyphs.size.width, height: glyphs.size.height)
            // Without these the view has no baseline of its own, so a
            // baseline-aligned stack falls back to its bottom edge — the
            // descender line, which sits further below the glyphs the larger
            // the font is. Two glass strings at different sizes would then
            // disagree about which line they stand on.
            .alignmentGuide(.firstTextBaseline) { _ in glyphs.baseline }
            .alignmentGuide(.lastTextBaseline) { _ in glyphs.baseline }
    }
}
