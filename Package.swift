// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UserMessage",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .visionOS(.v1)],
    products: [
        .library(
            name: "UserMessage",
            targets: ["UserMessage"]),
    ],
    targets: [
        .target(
            name: "UserMessage"),
    ]
)
