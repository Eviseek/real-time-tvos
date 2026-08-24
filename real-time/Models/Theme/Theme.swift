import SwiftUI

/// A named background palette.
///
/// A theme carries no digit colour: that is `ClockColor`, a preference the
/// viewer owns. Pairing the two in the catalog made it the designer's choice
/// and meant 35 themes each had to guess right.
struct Theme: Identifiable, Hashable, Sendable {
    /// Stable, code-defined identifier. This is what gets persisted — never
    /// the colors, so a palette can be retuned without migrating stored data.
    let id: String
    let name: String
    let background: BackgroundStyle
}
