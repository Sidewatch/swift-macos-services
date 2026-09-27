# Audit log

Last full audit: **27 Sep 2026**: created that day from Sidewatch's `AgentNotifications`, whose
test hook was a mutable global closure. Add a dated line under *History* when you audit again.

## What a full audit checks

1. `swift build` warnings (none allowed) and `swift test` green.
2. Every public declaration documented with `///`.
3. Every test mutation-verified.

## Known non-issues

- `post` asks for authorisation on every call. The system answers from its cache after the first
  prompt, and a user who changes the setting in System Settings is honoured on the next post.

## History

- 27 Sep 2026 — created; three tests.
