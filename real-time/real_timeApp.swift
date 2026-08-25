import SwiftUI

@main
struct real_timeApp: App {
    @State private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ClockScreen()
                .environment(\.settings, settings)
        }
    }
}
