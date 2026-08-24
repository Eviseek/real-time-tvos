import Foundation
import Observation

/// The app's single mutable store, as seen by views.
///
/// Conforms to `Observable` so SwiftUI's change tracking still works when the
/// store is held as an existential: reading a property through `any
/// AppSettingsProviding` goes through the same observed accessor as the
/// concrete type, so views re-render as normal.
@MainActor
protocol AppSettingsProviding: AnyObject, Observable {
    var themeID: String { get set }
    var timeZoneID: String { get set }
    var isAnimated: Bool { get set }

    /// The resolved theme for `themeID`, falling back when it is unknown.
    var theme: Theme { get }
    /// The resolved zone for `timeZoneID`, falling back to the device zone.
    var timeZone: TimeZone { get }
    /// Every selectable theme, grouped, so views never reach for the catalog
    /// directly.
    var themeCategories: [ThemeCategory] { get }
}
