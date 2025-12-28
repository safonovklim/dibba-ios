// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Dashboard",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Dashboard",
            targets: ["Dashboard"]
        ),
    ],
    targets: [
        .target(
            name: "Dashboard"
        ),
        .testTarget(
            name: "DashboardTests",
            dependencies: ["Dashboard"]
        ),
    ]
)
