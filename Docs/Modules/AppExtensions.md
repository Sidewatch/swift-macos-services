# Swift App Extensions

An app extension's on/off state for this user, read and flipped through `pluginkit` — for the
extension points macOS gives no API for: Quick Look previews and thumbnails, Spotlight, Share.
Extracted from [Sidewatch](https://github.com/Sidewatch), where it backs the
Settings switch for the Quick Look preview extension.

```swift
import AppExtensions

let preview = AppExtensionState(identifier: "app.sidewatch.Sidewatch.QuickLook",
                                appexURL: Bundle.main.bundleURL.appendingPathComponent("Contents/PlugIns/SidewatchQuickLook.appex"))
preview.isBundled          // the host carries the appex at all
preview.isEnabled()        // true / false / nil (not registered)
preview.setEnabled(true)   // registers if unknown, flips, returns whether the read-back agrees
AppExtensionState.openSystemSettings(extensionPoint: "com.apple.quicklook.preview")
```

`pluginkit -m -i` marks a plug-in `+` (in use), `-` (ignored) or `!` (blocked); `-e use|ignore`
flips it for this user — what System Settings ▸ General ▸ Login Items & Extensions does
underneath; `-a` registers a bundle Launch Services has not seen. There is no callback when the
user flips it elsewhere: read the state, never cache it. The `runner` is injectable, so tests
never touch the user's real extensions.

## Layout

- `Sources/AppExtensions/Core/AppExtensionState.swift` — the driver.
- `Tests/AppExtensionsTests` — parsing pluginkit's marks; flips and read-backs through a stand-in.

MIT. See CONTRIBUTING.md for the family rules.
