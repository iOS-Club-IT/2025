// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FancyButton",
    platforms: [
        .macOS(.v15), .iOS(.v18), .tvOS(.v18), .watchOS(.v11)
    ],
    products: [
        .library(
            name: "FancyButton",
            targets: ["FancyButton"]
        )
    ],
    targets: [
        .target(name: "FancyButton"),
        .testTarget(
            name: "FancyButtonTests",
            dependencies: ["FancyButton"]
        )
    ]
)
