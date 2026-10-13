//
//  ListeningPort.swift
//  ProcessFacts
//
//  A TCP port a process is listening on.
//
//  Created by David Sherlock on 10/13/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

/// A TCP port a process holds open in the LISTEN state — a dev server, a database, a debugger.
public struct ListeningPort: Hashable, Sendable {
    /// The local port number.
    public let port: UInt16
    /// The process holding the socket.
    public let pid: pid_t
    /// Whether the socket listens on loopback only (127.0.0.1 or ::1) rather than every address.
    public let isLoopbackOnly: Bool

    /// Creates a port record.
    public init(port: UInt16, pid: pid_t, isLoopbackOnly: Bool) {
        self.port = port
        self.pid = pid
        self.isLoopbackOnly = isLoopbackOnly
    }
}
