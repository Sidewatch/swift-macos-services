// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swift-notification-poster",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "NotificationPoster", targets: ["NotificationPoster"]),
    ],
    targets: [
        .target(name: "NotificationPoster", swiftSettings: [.swiftLanguageMode(.v6)]),
        .testTarget(name: "NotificationPosterTests", dependencies: ["NotificationPoster"],
                    swiftSettings: [.swiftLanguageMode(.v6)]),
    ]
)
