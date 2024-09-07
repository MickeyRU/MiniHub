// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "TimeZoneMiniApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "TimeZoneMiniApp",
            targets: ["TimeZoneMiniApp"]),
    ],
    dependencies: [
        .package(path: "../MiniAppInterface")
    ],
    targets: [
        .target(
            name: "TimeZoneMiniApp",
            dependencies: ["MiniAppInterface"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "TimeZoneMiniAppTests",
            dependencies: ["TimeZoneMiniApp"]),
    ],
    swiftLanguageVersions: [.v5]
)
