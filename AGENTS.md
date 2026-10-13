# Swift macOS Services

Small wrappers over macOS system services an app talks to: an app extension's on/off state through pluginkit, notifications behind a protocol, and facts about running processes.

- Modules `AppExtensions`, `NotificationPoster`, `ProcessFacts`, each in `Sources/<Module>` with tests in `Tests/<Module>Tests`; `swift test` is the whole check.
- Swift 6 language mode, tools 6.2, macOS 14+.
- Part of the Sidewatch package family; every package follows the same layout and PR rules.
- Each module's user-facing documentation is `Docs/Modules/<Module>.md`; its last audit is `Docs/Audits/<Module>.md` — read it before auditing, and extend it rather than redo it.

## AppExtensions — `Sources/AppExtensions`



## NotificationPoster — `Sources/NotificationPoster`

- Flat: Notice (the model), NotificationPosting (the protocol), SystemNotificationPoster (`UNUserNotificationCenter`; every title and body goes through NoticeText), RecordingNotificationPoster (the test double), NoticeText (text fit to show: C0/C1 controls and the Unicode bidi/format controls removed, title ≤ 256 and body ≤ 2,000 characters). A host that shows a program's own words — an OSC 777 notification, a prompt read off a screen — sanitises them with NoticeText before it builds the Notice too, so a recording double sees what the screen would.


## ProcessFacts — `Sources/ProcessFacts`

- `Models/` — ListeningPort. `Core/` — ProcessFacts (identity: name, path, argv, cwd, parent), +Tree (`descendants(of:)`), +Ports (`listeningPorts(_:)`). All `libproc`/`sysctl`, never a spawned tool; tests run against real child processes and real sockets.

## Rules

Read `CONTRIBUTING.md` for the folder layout and the pull-request rules.

@CONTRIBUTING.md
