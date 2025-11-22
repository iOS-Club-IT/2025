// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
//Although the swift-tools-version declaration is a comment, it will be parsed by the Swift Package Manager.

import PackageDescription

let package = Package(
    //Name defines the name of the package.When other packages depend on this package, they use this name to reference it.
    name: "Fancybutton",
    //Platforms specify the minimum platform versions for the package.
    platforms:[
        .iOS(.v15),
        .macOS(.v12)
    ],
    //Products define the executables and libraries a package produces, making them visible to other packages.
    products: [
        //.library creates a reusable code module that can be imported by other packages or applications.
        .library(
            name: "Fancybutton",//define the module name when imported.
            targets: ["Fancybutton"]//
        ),
    ],
    //dependencies define other packages that this package depends on.
    dependencies: [],
    //Targets are the basic building blocks of a package, defining a module or a test suite.
    //Targets can depend on other targets in this package or on products from package dependencies.
    targets: [
        .target(
            name: "Fancybutton"
        ),
        .testTarget(
            name: "FancybuttonTests",
            dependencies: ["Fancybutton"]
        ),
    ]
)
