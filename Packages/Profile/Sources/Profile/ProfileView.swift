import SwiftUI

public struct ProfileView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "gearshape.fill")
                .font(.largeTitle)
            Text("Settings")
        }
    }
}
