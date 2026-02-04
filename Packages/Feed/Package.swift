// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Feed",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Feed",
            targets: ["Feed"]
        ),
    ],
    dependencies: [
        .package(path: "../Servicing"),
    ],
    targets: [
        .target(
            name: "Feed",
            dependencies: ["Servicing"]
        ),
        .testTarget(
            name: "FeedTests",
            dependencies: ["Feed"]
        ),
    ]
)
