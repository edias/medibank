// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SourceSelection",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SourceSelection",
            targets: ["SourceSelection"]
        )
    ],
    dependencies: [
        .package(path: "../../Core/Network/RestClient"),
        .package(path: "../../Core/Storage")

    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SourceSelection",
            dependencies: [
                .product(name: "RestClient", package: "RestClient"),
                .product(name: "Storage", package: "Storage")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SourceSelectionTests",
            dependencies: ["SourceSelection"]
        )
    ]
)
