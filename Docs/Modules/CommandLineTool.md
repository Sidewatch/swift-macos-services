# Swift Command Line Tool

A command-line tool shipped inside an app bundle, linked into a folder on the PATH, the way VS Code
installs `code`. The link points into the bundle, so updating the app updates the tool.

- `CommandLineTool(name:source:directory:)` — the tool; `directory` defaults to `/usr/local/bin`.
- `state()` — what is at the link now: `.notInstalled`, `.installed` (a link to this source),
  `.linkedElsewhere(path)` (an older copy of the app, or another program's tool of that name) or
  `.occupied` (a file or folder that is not a link). Read it fresh: the person can change it from a shell.
- `install()` — links the tool, replacing a link or file already there (ask first), never a folder.
- `uninstall()` — removes the link only when it is this tool's.
- Both try as the person first. When the folder is not theirs to write (the usual case for
  `/usr/local/bin`), they run one shell command through `AdministratorShell`: AppleScript's
  `do shell script … with administrator privileges`, so macOS shows its own password prompt and
  the app never sees the password. Paths are single-quoted for the shell and escaped for the
  AppleScript literal. Unsandboxed apps only.

```swift
import CommandLineTool

let tool = CommandLineTool(
    name: "myapp", source: Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/bin/myapp"))
switch tool.state() {
case .installed: print("installed at \(tool.linkURL.path)")
case .notInstalled: _ = tool.install()
case .linkedElsewhere(let path): print("\(tool.linkURL.path) points at \(path); replace it?")
case .occupied: print("something else is called \(tool.name); replace it?")
}
```
