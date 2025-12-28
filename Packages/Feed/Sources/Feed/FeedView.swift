import SwiftUI

public struct FeedView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.largeTitle)
            Text("Feed")
        }
    }
}
