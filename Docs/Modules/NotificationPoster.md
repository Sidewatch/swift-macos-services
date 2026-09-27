# Swift Notification Poster

Shows macOS notifications through a protocol, so the logic deciding *when* to notify can be
tested without anything reaching Notification Center.

- `Notice` — title, body, identifier (a later notice with the same one replaces it), sound.
- `NotificationPosting` — `post(_:)`.
- `SystemNotificationPoster` — `UNUserNotificationCenter`, asking permission once; silent when it
  is refused or the process has no bundle identity (a bare binary, where the center would raise).
- `RecordingNotificationPoster` — keeps what it was asked to post, for tests and self-checks.

```swift
let poster: NotificationPosting = SystemNotificationPoster()
poster.post(Notice(title: "Claude needs you", body: "Allow edit to main.swift?", identifier: "pane-3"))
```

- Module `NotificationPoster`; `swift test` is the whole check. No dependencies.
- macOS 14, tools 6.2, Swift 6 language mode. MIT licence. Copyright © 2026 ArrayPress Limited.
