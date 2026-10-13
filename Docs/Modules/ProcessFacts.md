# Swift Process Facts

Facts about running processes, read straight from the kernel (`libproc` and `sysctl`): no tool is
spawned, so a call costs microseconds and a poll can afford it. Every reader answers nil (or empty)
for a process that is gone or belongs to another user.

- `ProcessFacts.name(_:)`, `executablePath(_:)`, `arguments(_:)`, `workingDirectory(_:)`, `parent(_:)`
  — a process's identity. `arguments` reads exactly `argc` strings from `KERN_PROCARGS2`, never the
  environment that follows them.
- `ProcessFacts.descendants(of:)` — every process whose ancestry reaches a pid (children,
  grandchildren, …), from one pass over the process table.
- `ProcessFacts.listeningPorts(_:)` — the TCP ports a process holds in LISTEN, as `ListeningPort`
  (port, pid, whether it listens on loopback only): what `lsof -iTCP -sTCP:LISTEN` reports, without
  spawning it. A port bound on IPv4 and IPv6 appears once.

```swift
import ProcessFacts

// The servers a terminal's shell has started, however deep in the tree.
let servers = ProcessFacts.descendants(of: shellPID).flatMap(ProcessFacts.listeningPorts)
for s in servers {
    print("localhost:\(s.port)", ProcessFacts.name(s.pid) ?? "?", ProcessFacts.arguments(s.pid) ?? [])
}
```
