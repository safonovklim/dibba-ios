import os.log
import SwiftUI

private let logger = Logger(subsystem: "ai.dibba.ios", category: "DashboardView")

public struct DashboardView: View {
    public init() {
        logger.debug("init")
    }

    public var body: some View {
        let _ = logger.debug("body rendered")
        VStack(spacing: 12) {
            Image(systemName: "rectangle.grid.2x2")
                .font(.largeTitle)
            Text("Dashboard")
        }
    }
}
