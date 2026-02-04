// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Auth",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Auth",
            targets: ["Auth"]
        ),
    ],
    dependencies: [
        .package(path: "../Navigation"),
        .package(url: "https://github.com/auth0/Auth0.swift", from: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Auth",
            dependencies: [
                "Navigation",
                .product(name: "Auth0", package: "Auth0.swift"),
            ]
        ),
        .testTarget(
            name: "AuthTests",
            dependencies: ["Auth"]
        ),
    ]
)
