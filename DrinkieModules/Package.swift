// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DrinkieModules",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DRAPI", targets: ["DRAPI"]),
        .library(name: "DRUIKit", targets: ["DRUIKit"]),
        .library(name: "Menu", targets: ["Menu"]),
    ],
    targets: [
        .target(name: "DRAPI"),
        .target(name: "DRUIKit"),
        .target(name: "Menu", dependencies: ["DRAPI", "DRUIKit"]),
    ]
)
