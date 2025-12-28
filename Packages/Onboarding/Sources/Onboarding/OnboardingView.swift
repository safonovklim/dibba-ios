import SwiftUI

public struct OnboardingView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.wave.circle")
                .font(.largeTitle)
            Text("Onboarding")
        }
    }
}
