//
//  ProcessFacts+Tree.swift
//  ProcessFacts
//
//  Every process descended from a given one.
//
//  Created by David Sherlock on 10/13/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Darwin
import Foundation

extension ProcessFacts {
    /// Every running process whose ancestry reaches `root` — its children, theirs, and so on —
    /// not `root` itself. One pass over the process table: each process's parent is read once.
    public static func descendants(of root: pid_t) -> [pid_t] {
        guard root > 0 else { return [] }
        var children: [pid_t: [pid_t]] = [:]
        for pid in allPIDs() where pid > 0 {
            if let parent = parent(pid) { children[parent, default: []].append(pid) }
        }
        var out: [pid_t] = []
        var queue = children[root] ?? []
        while let next = queue.popLast() {
            out.append(next)
            queue += children[next] ?? []
        }
        return out.sorted()
    }

    /// Every pid in the process table (`proc_listallpids`), with headroom for processes that start
    /// between the size query and the read.
    static func allPIDs() -> [pid_t] {
        let count = proc_listallpids(nil, 0)
        guard count > 0 else { return [] }
        var pids = [pid_t](repeating: 0, count: Int(count) + 64)
        let filled = pids.withUnsafeMutableBytes { proc_listallpids($0.baseAddress, Int32($0.count)) }
        guard filled > 0 else { return [] }
        return Array(pids.prefix(Int(filled)))
    }
}
