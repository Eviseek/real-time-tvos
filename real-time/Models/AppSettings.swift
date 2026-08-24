import Foundation
import Observation

@Observable
final class AppSettings: AppSettingsProviding {
    private enum Keys {
        static let themeID = "themeID"
        static let timeZoneID = "timeZoneID"
        static let isAnimated = "isAnimated"
    }

    private let defaults: UserDefaults
    private let themes: any ThemeProviding

    // @AppStorage cannot be used inside a class, so persistence is explicit:
    // read once in init, write on every mutation. didSet does not fire during
    // init, so init performs no redundant writes.
    var themeID: String { didSet { defaults.set(themeID, forKey: Keys.themeID) } }
    var timeZoneID: String { didSet { defaults.set(timeZoneID, forKey: Keys.timeZoneID) } }
    var isAnimated: Bool { didSet { defaults.set(isAnimated, forKey: Keys.isAnimated) } }

    init(defaults: UserDefaults = .standard, themes: any ThemeProviding = ThemeCatalog.shared) {
        self.defaults = defaults
        self.themes = themes
        self.themeID = defaults.string(forKey: Keys.themeID) ?? themes.defaultTheme.id
        self.timeZoneID = defaults.string(forKey: Keys.timeZoneID) ?? TimeZone.current.identifier
        // `object(forKey:)` rather than `bool(forKey:)`: the latter returns
        // false for a missing key, which would silently default to no motion.
        self.isAnimated = defaults.object(forKey: Keys.isAnimated) as? Bool ?? true
    }

    var theme: Theme { themes.theme(id: themeID) }
    var timeZone: TimeZone { TimeZone(identifier: timeZoneID) ?? .current }
    var availableThemes: [Theme] { themes.all }
}
