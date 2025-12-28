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
    targets: [
        .target(
            name: "Feed"
        ),
        .testTarget(
            name: "FeedTests",
            dependencies: ["Feed"]
        ),
    ]
)
