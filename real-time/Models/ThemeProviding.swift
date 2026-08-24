/// Supplies the available themes, grouped, and resolves persisted identifiers.
///
/// A protocol rather than static members on `ThemeCatalog` so a test or
/// preview can inject a two-theme catalog instead of the full set.
protocol ThemeProviding: Sendable {
    var categories: [ThemeCategory] { get }
    var defaultTheme: Theme { get }

    /// Resolves a persisted identifier, falling back to `defaultTheme` when
    /// it no longer exists.
    func theme(id: String) -> Theme
}
