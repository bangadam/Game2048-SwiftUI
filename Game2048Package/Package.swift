// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Game2048Feature",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Game2048Feature",
            targets: ["Game2048Feature"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Game2048Feature",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "Game2048FeatureTests",
            dependencies: [
                "Game2048Feature"
            ]
        ),
    ]
)
