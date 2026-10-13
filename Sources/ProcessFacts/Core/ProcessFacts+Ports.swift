//
//  ProcessFacts+Ports.swift
//  ProcessFacts
//
//  The TCP ports a process is listening on, from its own file descriptors.
//
//  Created by David Sherlock on 10/13/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Darwin
import Foundation

extension ProcessFacts {
    /// The TCP ports `pid` holds in the LISTEN state, read from its descriptor table
    /// (`PROC_PIDLISTFDS`, then `PROC_PIDFDSOCKETINFO` per socket) — what `lsof -iTCP -sTCP:LISTEN`
    /// reports, without spawning it. A port bound on both IPv4 and IPv6 appears once.
    public static func listeningPorts(_ pid: pid_t) -> [ListeningPort] {
        var seen: [UInt16: ListeningPort] = [:]
        for fd in socketDescriptors(pid) {
            var info = socket_fdinfo()
            let size = Int32(MemoryLayout<socket_fdinfo>.size)
            guard proc_pidfdinfo(pid, fd, PROC_PIDFDSOCKETINFO, &info, size) == size,
                info.psi.soi_kind == SOCKINFO_TCP
            else { continue }
            let tcp = info.psi.soi_proto.pri_tcp
            guard tcp.tcpsi_state == TSI_S_LISTEN else { continue }
            let port = UInt16(bigEndian: UInt16(truncatingIfNeeded: tcp.tcpsi_ini.insi_lport))
            guard port > 0 else { continue }
            let loopback = isLoopback(tcp.tcpsi_ini, family: info.psi.soi_family)
            // Listening on every address beats loopback-only when the same port appears twice.
            if let existing = seen[port], !existing.isLoopbackOnly { continue }
            seen[port] = ListeningPort(port: port, pid: pid, isLoopbackOnly: loopback)
        }
        return seen.values.sorted { $0.port < $1.port }
    }

    /// `pid`'s open socket descriptors.
    private static func socketDescriptors(_ pid: pid_t) -> [Int32] {
        guard pid > 0 else { return [] }
        let bytes = proc_pidinfo(pid, PROC_PIDLISTFDS, 0, nil, 0)
        guard bytes > 0 else { return [] }
        let stride = MemoryLayout<proc_fdinfo>.stride
        var fds = [proc_fdinfo](repeating: proc_fdinfo(), count: Int(bytes) / stride + 16)
        let filled = fds.withUnsafeMutableBytes { proc_pidinfo(pid, PROC_PIDLISTFDS, 0, $0.baseAddress, Int32($0.count)) }
        guard filled > 0 else { return [] }
        return fds.prefix(Int(filled) / stride).filter { $0.proc_fdtype == PROX_FDTYPE_SOCKET }.map(\.proc_fd)
    }

    /// Whether a listening socket's local address is loopback (127.0.0.0/8 or ::1).
    private static func isLoopback(_ addr: in_sockinfo, family: Int32) -> Bool {
        if family == AF_INET {
            let v4 = UInt32(bigEndian: addr.insi_laddr.ina_46.i46a_addr4.s_addr)
            return v4 >> 24 == 127
        }
        if family == AF_INET6 {
            return withUnsafeBytes(of: addr.insi_laddr.ina_6) { raw in
                raw.prefix(15).allSatisfy { $0 == 0 } && raw[15] == 1
            }
        }
        return false
    }
}
