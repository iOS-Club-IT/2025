// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClubUI",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "ClubUI", targets: ["ClubUI"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "ClubUI", dependencies: []),
    ]
)
