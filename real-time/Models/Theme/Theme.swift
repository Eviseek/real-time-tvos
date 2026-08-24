import SwiftUI

/// A curated pairing of a background and a foreground.
///
/// Backgrounds and foregrounds are never chosen independently: a glass
/// foreground is unreadable over a solid background, and a light foreground
/// disappears on a light one. Pairing them in a single value makes an
/// unreadable combination unrepresentable.
struct Theme: Identifiable, Hashable, Sendable {
    /// Stable, code-defined identifier. This is what gets persisted — never
    /// the colors, so a palette can be retuned without migrating stored data.
    let id: String
    let name: String
    let background: BackgroundStyle
    let foreground: ForegroundStyle
}
