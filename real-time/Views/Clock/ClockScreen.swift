import SwiftUI

struct ClockScreen: View {
    @Environment(\.settings) private var settings

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text(settings.theme.name)
                .font(.largeTitle)
                .foregroundStyle(.white)
        }
    }
}
