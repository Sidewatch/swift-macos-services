# Swift Notification Poster

Shows macOS notifications through a protocol, so the logic deciding *when* to notify can be
tested without anything reaching Notification Center.

- `Notice` — title, body, identifier (a later notice with the same one replaces it), sound.
- `NotificationPosting` — `post(_:)`.
- `SystemNotificationPoster` — `UNUserNotificationCenter`, asking permission once; silent when it
  is refused or the process has no bundle identity (a bare binary, where the center would raise).
- `RecordingNotificationPoster` — keeps what it was asked to post, for tests and self-checks.
- `NoticeText` — `title(_:)` / `body(_:)` / `sanitized(_:cap:)`: a program's own words made fit to show. C0 and C1 controls (but a body's line feeds and tabs), DEL, and the Unicode controls that reorder or hide text (U+200B–U+200F, U+202A–U+202E, U+2066–U+2069) are removed; a title is cut at 256 characters and a body at 2,000, with an ellipsis. `SystemNotificationPoster` applies it to every request; a host building a `Notice` from a terminal's output applies it first, so a recording double sees the same text.

```swift
let poster: NotificationPosting = SystemNotificationPoster()
poster.post(Notice(title: "Claude needs you", body: "Allow edit to main.swift?", identifier: "pane-3"))

// A program's OSC 777 notification, sanitised before it becomes a Notice.
poster.post(Notice(title: NoticeText.title("claude: " + oscTitle), body: NoticeText.body(oscBody)))
```

- Module `NotificationPoster`; `swift test` is the whole check. No dependencies.
- macOS 14, tools 6.2, Swift 6 language mode. MIT licence. Copyright © 2026 ArrayPress Limited.
