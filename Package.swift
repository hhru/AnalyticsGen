// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnalyticsGen",
    platforms: [
       .macOS(.v10_12)
    ],
    dependencies: [
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.0"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.9.2"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
        .package(url: "https://github.com/mxcl/PromiseKit", from: "6.8.0"),
        .package(url: "https://github.com/kylef/Stencil.git", from: "0.13.0"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.7.2"),
        .package(url: "https://github.com/almazrafi/DictionaryCoder.git", from: "1.0.2")
    ],
    targets: [
        .target(
            name: "AnalyticsGen",
            dependencies: [
                "AnalyticsGenTools",
                "SwiftCLI",
                "PathKit",
                "Rainbow",
                "PromiseKit",
                "Stencil",
                "StencilSwiftKit",
                "DictionaryCoder"
            ]
        ),
        .target(
            name: "AnalyticsGenTools",
            dependencies: ["SwiftCLI", "PathKit"]
        ),
        .testTarget(
            name: "AnalyticsGenTests",
            dependencies: ["AnalyticsGen"]
        )
    ]
)
