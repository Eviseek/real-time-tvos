import SwiftUI

extension EnvironmentValues {
    /// The settings store, injected as a protocol.
    ///
    /// A custom entry rather than `.environment(AppSettings.self)`: that API
    /// keys on a concrete `@Observable` class and cannot carry an existential.
    @Entry var settings: any AppSettingsProviding = AppSettings()
}
