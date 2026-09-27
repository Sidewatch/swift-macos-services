// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swift-macos-services",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "AppExtensions", targets: ["AppExtensions"]),
        .library(name: "NotificationPoster", targets: ["NotificationPoster"]),
    ],
    dependencies: [
        .package(path: "../swift-foundation-extensions"),
    ],
    targets: [
        .target(name: "AppExtensions", dependencies: [.product(name: "ProcessRunner", package: "swift-foundation-extensions")],
                swiftSettings: [.swiftLanguageMode(.v6)]),
        .target(name: "NotificationPoster", swiftSettings: [.swiftLanguageMode(.v6)]),
        .testTarget(name: "AppExtensionsTests", dependencies: ["AppExtensions"]),
        .testTarget(name: "NotificationPosterTests", dependencies: ["NotificationPoster"], swiftSettings: [.swiftLanguageMode(.v6)]),
    ]
)
