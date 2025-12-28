import SwiftUI

public struct LoginView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.largeTitle)
            Text("Login")
        }
    }
}
