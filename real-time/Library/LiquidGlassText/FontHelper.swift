import UIKit

/// Builds the `UIFont` that `LiquidGlassText` traces into a glyph path.
///
/// `TextHelper` needs a real font object to hand to CoreText, which
/// `clockDigitFont(size:)`'s SwiftUI `.font()` modifier can't supply — that
/// modifier never touches a view that renders through `glassEffect` instead
/// of `Text`. This rebuilds the same treatment (semibold, rounded,
/// monospaced digits) as a `UIFont` so both renderers stay visually matched.
struct FontHelper {
    private init() {}

    static func clockFont(size: CGFloat) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: .semibold)
        let rounded = base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor
        let monospacedDigits = rounded.addingAttributes([
            .featureSettings: [[
                UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector,
            ]]
        ])
        return UIFont(descriptor: monospacedDigits, size: size)
    }
}
