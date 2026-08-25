import SwiftUI
import CoreText

/// Traces a string's glyph outlines into a single `Path`, alongside the fixed
/// frame that path was traced into.
///
/// `glassEffect` fills a `Shape`, and `Text` isn't one — so `LiquidGlassText`
/// needs the glyphs themselves as geometry rather than as a rendered string.
struct TextHelper {
    private init() {}

    /// The frame is measured from the font's typographic metrics, never from
    /// the path's own ink bounds: ink bounds are tight to whichever glyphs
    /// happen to be on screen, and digits vary — a "1" sits further from the
    /// frame edge than an "8" even though `.monospacedDigit()` gives them the
    /// same advance width. Sizing to ink would resize (and visibly shift) the
    /// glass shape on every tick; the typographic frame does not.
    static func path(for text: String, font: UIFont) -> (path: Path, size: CGSize) {
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [.font: font]))
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]

        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var leading: CGFloat = 0
        let width = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))

        let outputPath = CGMutablePath()
        for run in runs {
            let attributes = CTRunGetAttributes(run) as NSDictionary
            guard let ctFont = attributes[kCTFontAttributeName as NSAttributedString.Key] else { continue }

            let glyphCount = CTRunGetGlyphCount(run)
            var glyphs = [CGGlyph](repeating: 0, count: glyphCount)
            var positions = [CGPoint](repeating: .zero, count: glyphCount)
            CTRunGetGlyphs(run, CFRangeMake(0, 0), &glyphs)
            CTRunGetPositions(run, CFRangeMake(0, 0), &positions)

            for index in 0..<glyphCount {
                guard let glyphPath = CTFontCreatePathForGlyph(ctFont as! CTFont, glyphs[index], nil) else { continue }
                let transform = CGAffineTransform(translationX: positions[index].x, y: positions[index].y)
                outputPath.addPath(glyphPath, transform: transform)
            }
        }

        // CoreText's baseline sits at y = 0 with y increasing upward; SwiftUI
        // draws with y increasing downward from the frame's top. Flipping
        // about the font's ascent — not this string's ink bounds — keeps the
        // baseline at the same frame position for every tick.
        let flip = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: ascent)
        let size = CGSize(width: width, height: ascent + descent)
        return (Path(outputPath).applying(flip), size)
    }
}
