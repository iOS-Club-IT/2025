// swift-tools-version: 5.7
// (使用 5.7 或更高版本以支持 iOS 15+)

import PackageDescription

let package = Package(
    name: "ClubUI",
    // 声明支持的最低平台，SwiftUI 需要 iOS
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // 定义两个可以被 App 导入的库
        .library(
            name: "FancyButton",
            targets: ["FancyButton"]),
        .library(
            name: "GradientText",
            targets: ["GradientText"]),
    ],
    dependencies: [
        // 本作业不需要外部依赖
    ],
    targets: [
        // 定义 FancyButton 模块
        .target(
            name: "FancyButton",
            dependencies: []), // 没有依赖

        // 定义 GradientText 模块
        .target(
            name: "GradientText",
            dependencies: []), // 保持独立
        

    ]

)
