import SwiftUI

extension Color {
    /// Builds a color from a 6-digit RGB hex literal, e.g. `0x101528`.
    ///
    /// Takes an integer rather than a string: a palette is fixed at compile
    /// time, so there is no reason to accept a value that can fail to parse.
    /// `nonisolated` because the project defaults actor isolation to
    /// `MainActor`, and the palette is built in static context.
    nonisolated init(hex: UInt32) {
        // Shift each channel down to the low byte, mask it off, and scale the
        // 0-255 byte into the 0-1 range SwiftUI expects.
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
