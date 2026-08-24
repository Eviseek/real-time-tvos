import SwiftUI

extension View {
    /// The clock's type treatment.
    ///
    /// Shared by the full-size face, the glass renderer, and the theme tile
    /// previews, so a preview cannot drift from what it is previewing.
    /// `.monospacedDigit()` is the point: without it, glyph widths differ and
    /// the whole string shifts sideways every time a digit changes.
    func clockDigitFont(size: CGFloat) -> some View {
        self
            .font(.system(size: size, weight: .semibold, design: .rounded))
            .monospacedDigit()
    }
}
