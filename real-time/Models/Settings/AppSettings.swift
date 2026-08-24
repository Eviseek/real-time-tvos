import Foundation
import Observation

@Observable
final class AppSettings: AppSettingsProviding {
    private enum Keys {
        static let themeID = "themeID"
        static let timeZoneID = "timeZoneID"
        static let isAnimated = "isAnimated"
        static let clockColor = "clockColor"
    }

    private let defaults: UserDefaults
    private let themes: any ThemeProviding

    // @AppStorage cannot be used inside a class, so persistence is explicit:
    // read once in init, write on every mutation. didSet does not fire during
    // init, so init performs no redundant writes.
    var themeID: String { didSet { defaults.set(themeID, forKey: Keys.themeID) } }
    var timeZoneID: String { didSet { defaults.set(timeZoneID, forKey: Keys.timeZoneID) } }
    var isAnimated: Bool { didSet { defaults.set(isAnimated, forKey: Keys.isAnimated) } }
    var clockColor: ClockColor { didSet { defaults.set(clockColor.rawValue, forKey: Keys.clockColor) } }

    init(defaults: UserDefaults = .standard, themes: any ThemeProviding = ThemeCatalog.shared) {
        self.defaults = defaults
        self.themes = themes
        self.themeID = defaults.string(forKey: Keys.themeID) ?? themes.defaultTheme.id
        self.timeZoneID = defaults.string(forKey: Keys.timeZoneID) ?? TimeZone.current.identifier
        // `object(forKey:)` rather than `bool(forKey:)`: the latter returns
        // false for a missing key, which would silently default to no motion.
        self.isAnimated = defaults.object(forKey: Keys.isAnimated) as? Bool ?? true
        // Falls back to `.light` both when unset and when a stored value no
        // longer maps to a case, the same way an unknown theme ID does.
        self.clockColor = defaults.string(forKey: Keys.clockColor)
            .flatMap { ClockColor(rawValue: $0) } ?? .light
    }

    var theme: Theme { themes.theme(id: themeID) }
    var timeZone: TimeZone { TimeZone(identifier: timeZoneID) ?? .current }
    var themeCategories: [ThemeCategory] { themes.categories }
    var clockForeground: ForegroundStyle { clockColor.style(for: theme) }
}
