# Swift macOS Services

Small wrappers over macOS system services an app talks to: an app extension's on/off state through pluginkit, and notifications behind a protocol.

## Modules

Each module is its own library product: depend on the package, then only on the products you use.

| Module | What it is |
|---|---|
| [`AppExtensions`](Docs/Modules/AppExtensions.md) | An app extension's on/off state for this user, read and flipped through `pluginkit`. |
| [`NotificationPoster`](Docs/Modules/NotificationPoster.md) | macOS notifications behind a protocol, so the logic deciding when to notify can be tested. |

## Requirements

- macOS 14+
- Swift 6.2+ (Swift 6 language mode)

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/Sidewatch/swift-macos-services.git", from: "0.1.0")
],
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "AppExtensions", package: "swift-macos-services"),
    ]),
]
```

## Usage

### AppExtensions

See [Docs/Modules/AppExtensions.md](Docs/Modules/AppExtensions.md).

### NotificationPoster

See [Docs/Modules/NotificationPoster.md](Docs/Modules/NotificationPoster.md).

Each module's full guide is `Docs/Modules/<Module>.md`.

## Notes

The modules were separate packages until 27 September 2026 (`swift-app-extensions`, `swift-notification-poster`); their commits are kept here, so `git log --follow` traces any file back through them.

## For agents

Read `CONTRIBUTING.md` first: the folder layout and the PR rules. `swift test` is the whole
check, and a new test must fail before the change it covers. `CLAUDE.md` / `AGENTS.md` carry a
module map.

## License

MIT — see [LICENSE](LICENSE).
