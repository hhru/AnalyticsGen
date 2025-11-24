// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnalyticsGen",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(name: "analyticsgen", targets: ["AnalyticsGen"]),
        .library(name: "AnalyticsGenTools", targets: ["AnalyticsGenTools"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.0"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
        .package(url: "https://github.com/kylef/Stencil.git", from: "0.15.1"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.10.1"),
        .package(url: "https://github.com/almazrafi/DictionaryCoder.git", from: "1.0.4"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.4"),
        .package(url: "https://github.com/kylef/JSONSchema.swift.git", from: "0.5.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2")
    ],
    targets: [
        .executableTarget(
            name: "AnalyticsGen",
            dependencies: [
                "AnalyticsGenTools",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "PathKit", package: "PathKit"),
                .product(name: "Rainbow", package: "Rainbow"),
                .product(name: "Stencil", package: "Stencil"),
                .product(name: "StencilSwiftKit", package: "StencilSwiftKit"),
                .product(name: "DictionaryCoder", package: "DictionaryCoder"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "JSONSchema", package: "jsonschema.swift"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
                .product(name: "KeychainAccess", package: "KeychainAccess")
            ]
        ),
        .target(
            name: "AnalyticsGenTools",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "PathKit", package: "PathKit")
            ]
        ),
        .testTarget(
            name: "AnalyticsGenTests",
            dependencies: ["AnalyticsGen"]
        )
    ]
)
