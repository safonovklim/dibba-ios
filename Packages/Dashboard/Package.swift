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
    dependencies: [
        .package(path: "../Navigation"),
        .package(path: "../Feed"),
        .package(path: "../Profile"),
        .package(path: "../Auth"),
    ],
    targets: [
        .target(
            name: "Dashboard",
            dependencies: [
                "Navigation",
                "Feed",
                "Profile",
                "Auth",
            ]
        ),
        .testTarget(
            name: "DashboardTests",
            dependencies: ["Dashboard"]
        ),
    ]
)
