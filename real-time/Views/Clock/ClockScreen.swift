import SwiftUI

struct ClockScreen: View {
    @Environment(\.settings) private var settings

    var body: some View {
        ZStack {
            BackgroundView(style: settings.theme.background, isAnimating: settings.isAnimated)
            Text(settings.theme.name)
                .font(.largeTitle)
                .foregroundStyle(.white)
        }
    }
}
