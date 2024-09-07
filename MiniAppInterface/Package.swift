// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MiniAppInterface",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MiniAppInterface",
            targets: ["MiniAppInterface"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MiniAppInterface",
            dependencies: []),
        .testTarget(
            name: "MiniAppInterfaceTests",
            dependencies: ["MiniAppInterface"]),
    ],
    swiftLanguageVersions: [.v5]
)
