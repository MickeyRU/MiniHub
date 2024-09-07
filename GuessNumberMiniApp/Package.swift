// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "GuessNumberMiniApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "GuessNumberMiniApp",
            targets: ["GuessNumberMiniApp"]),
    ],
    dependencies: [
        .package(path: "../MiniAppInterface")
    ],
    targets: [
        .target(
            name: "GuessNumberMiniApp",
            dependencies: ["MiniAppInterface"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "GuessNumberMiniAppTests",
            dependencies: ["GuessNumberMiniApp"]),
    ],
    swiftLanguageVersions: [.v5]
)
