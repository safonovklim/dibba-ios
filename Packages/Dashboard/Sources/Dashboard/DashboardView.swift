import SwiftUI

public struct DashboardView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.grid.2x2")
                .font(.largeTitle)
            Text("Dashboard")
        }
    }
}
