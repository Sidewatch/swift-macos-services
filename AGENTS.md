# Swift Notification Poster

macOS notifications behind a protocol: `Notice`, `NotificationPosting`, `SystemNotificationPoster`
(UserNotifications) and `RecordingNotificationPoster` (tests). Hosts inject a poster rather than
call the notification center, so a test can prove what would have been shown.

- Module `NotificationPoster` in `Sources/NotificationPoster`; tests in `Tests/NotificationPosterTests`.
- No dependencies. macOS 14, tools 6.2, Swift 6 language mode.
- `SystemNotificationPoster.post` cannot run under `swift test` (it would ask for permission); the
  request it builds is a static function so the content is still tested.

@CONTRIBUTING.md
