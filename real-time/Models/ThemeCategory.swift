import SwiftUI

/// A named group of themes, shown as one segment in the theme picker.
///
/// Categories are a mood, not a technical distinction: they exist so someone
/// browsing 22 themes can jump to the handful that suit the room they are in.
struct ThemeCategory: Identifiable, Hashable, Sendable {
    let id: String
    let name: String

    /// Stops used to tint this category's segment in the picker, dark to
    /// light. Separate from any one theme's colors, because a segment has to
    /// stand for the whole group.
    let segment: [Color]

    let themes: [Theme]

    func contains(themeID: String) -> Bool {
        themes.contains { $0.id == themeID }
    }
}
