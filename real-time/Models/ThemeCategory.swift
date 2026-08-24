import SwiftUI

/// A named group of themes, shown as one titled section in the theme list.
///
/// Categories are a mood, not a technical distinction: they exist so someone
/// scrolling 22 themes can find the handful that suit the room they are in.
struct ThemeCategory: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let themes: [Theme]
}
