//
//  ListeningProcess.swift
//  ProcessFacts
//
//  A process accepting connections on a port, and the process tree it was found under.
//
//  Created by David Sherlock on 10/21/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Darwin
import Foundation

/// A server one of a set of root processes started: the port it listens on, the process, its command
/// line, and which root's tree it is in (a terminal's shell, say).
public struct ListeningProcess: Hashable, Sendable {
    /// The listening port.
    public let port: UInt16
    /// The process holding it.
    public let pid: pid_t
    /// Its command line (`argv`), or its name alone when the arguments cannot be read.
    public let arguments: [String]
    /// The root process whose tree it was found in.
    public let root: pid_t

    /// A listening process.
    public init(port: UInt16, pid: pid_t, arguments: [String], root: pid_t) {
        self.port = port
        self.pid = pid
        self.arguments = arguments
        self.root = root
    }
}
