import SwiftUI

/// Timing for the auto-hiding settings bar.
///
/// Behavioural rather than layout values, so they live here beside the
/// modifier that uses them rather than in `Metrics`.
enum OverlayReveal {
    /// How long the bar stays up after the last press. Long enough to read the
    /// controls and aim at one, short enough that a stray press does not leave
    /// chrome sitting on a clock meant to be looked at.
    static let visibleDuration = Duration.seconds(5)

    /// Fast enough to read as a response to the press rather than an
    /// animation the user waits through.
    static let transition = Animation.easeInOut(duration: 0.25)
}
