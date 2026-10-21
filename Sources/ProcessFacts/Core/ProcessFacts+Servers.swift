//
//  ProcessFacts+Servers.swift
//  ProcessFacts
//
//  The servers running under a set of processes.
//
//  Created by David Sherlock on 10/21/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Darwin
import Foundation

public extension ProcessFacts {
    /// Every port a descendant of `roots` listens on, ONE process per port (the first found: the earlier
    /// root, then the tree's order), ordered by port. A process table walk and a socket read per
    /// descendant: call it off the main thread.
    static func listeningProcesses(under roots: [pid_t]) -> [ListeningProcess] {
        var byPort: [UInt16: ListeningProcess] = [:]
        for root in roots {
            for pid in descendants(of: root) {
                for listening in listeningPorts(pid) where byPort[listening.port] == nil {
                    let arguments = self.arguments(pid) ?? [name(pid) ?? "?"]
                    byPort[listening.port] = ListeningProcess(port: listening.port, pid: pid, arguments: arguments, root: root)
                }
            }
        }
        return byPort.values.sorted { $0.port < $1.port }
    }
}

public extension ListeningProcess {
    /// The first three words of the command line, each path cut to its last component
    /// (`node /…/.bin/vite --port 5173` → `node vite --port`) — enough to tell servers apart in a menu.
    var shortCommand: String {
        arguments.prefix(3).map { $0.contains("/") ? URL(fileURLWithPath: $0).lastPathComponent : $0 }.joined(separator: " ")
    }
}
