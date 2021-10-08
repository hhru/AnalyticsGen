// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnalyticsGen",
    platforms: [
       .macOS(.v10_12)
    ],
    products: [
        .executable(name: "analyticsgen", targets: ["AnalyticsGen"]),
        .library(name: "AnalyticsGenTools", targets: ["AnalyticsGenTools"])
    ],
    dependencies: [
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.3"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
        .package(url: "https://github.com/mxcl/PromiseKit", from: "6.8.0"),
        .package(url: "https://github.com/kylef/Stencil.git", from: "0.13.0"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.7.2"),
        .package(url: "https://github.com/almazrafi/DictionaryCoder.git", from: "1.0.4"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.4"),
        .package(url: "https://github.com/kylef/JSONSchema.swift.git", from: "0.5.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))
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
                "DictionaryCoder",
                "Yams",
                "JSONSchema",
                "ZIPFoundation"
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
