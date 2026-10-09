# Audit log

Last full audit: **27 Sep 2026**: created that day from Sidewatch's `AgentNotifications`, whose
test hook was a mutable global closure. Add a dated line under *History* when you audit again.

## What a full audit checks

1. `swift build` warnings (none allowed) and `swift test` green.
2. Every public declaration documented with `///`.
3. Every test mutation-verified.

## Security review — 9 Oct 2026

- **A program's text reached Notification Center verbatim.** An OSC 777 title and body went to
  `UNUserNotificationCenter` as the terminal program wrote them: control characters, a
  right-to-left override that rewrites what the eye reads, a body of any length. `NoticeText`
  removes C0/C1 controls (a body keeps its line feeds and tabs), DEL and U+200B–U+200F,
  U+202A–U+202E, U+2066–U+2069, and caps a title at 256 and a body at 2,000 characters;
  `SystemNotificationPoster.request(for:)` applies it to every notice. `NoticeTextTests` (three
  tests). Mutants: the bidi range kept, and the request taking the raw title — three failures.

## Known non-issues

- `post` asks for authorisation on every call. The system answers from its cache after the first
  prompt, and a user who changes the setting in System Settings is honoured on the next post.

## History

- 27 Sep 2026 — created; three tests.
- 9 Oct 2026 — security review: `NoticeText` (section above); six tests.
