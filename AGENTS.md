# Swift macOS Services

Small wrappers over macOS system services an app talks to: an app extension's on/off state through pluginkit, and notifications behind a protocol.

- Modules `AppExtensions`, `NotificationPoster`, each in `Sources/<Module>` with tests in `Tests/<Module>Tests`; `swift test` is the whole check.
- Swift 6 language mode, tools 6.2, macOS 14+.
- Part of the Sidewatch package family; every package follows the same layout and PR rules.
- Each module's user-facing documentation is `Docs/Modules/<Module>.md`; its last audit is `Docs/Audits/<Module>.md` — read it before auditing, and extend it rather than redo it.

## AppExtensions — `Sources/AppExtensions`



## NotificationPoster — `Sources/NotificationPoster`



## Rules

Read `CONTRIBUTING.md` before changing anything: it is the layout and PR rulebook for this package.
