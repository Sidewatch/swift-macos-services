//
//  ProcessFacts.swift
//  ProcessFacts
//
//  A running process's identity, read from the kernel: its name, executable, arguments, working
//  directory and parent.
//
//  Created by David Sherlock on 10/13/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Darwin
import Foundation

/// Facts about running processes, read from the kernel (`libproc` and `sysctl`) — no tool is
/// spawned, so each call costs microseconds. Every reader answers nil (or empty) for a process
/// that is gone or belongs to another user.
public enum ProcessFacts {
    /// `pid`'s accounting name (`claude`, `node`, `vim`) via `proc_name`.
    public static func name(_ pid: pid_t) -> String? {
        guard pid > 0 else { return nil }
        var buf = [CChar](repeating: 0, count: 256)
        guard proc_name(pid, &buf, UInt32(buf.count)) > 0 else { return nil }
        let name = buf.withUnsafeBufferPointer { String(cString: $0.baseAddress!) }
        return name.isEmpty ? nil : name
    }

    /// `pid`'s full executable path via `proc_pidpath`. `name` alone cannot tell a binary named
    /// after its version (`…/claude/versions/2.1.223`) from any other.
    public static func executablePath(_ pid: pid_t) -> String? {
        guard pid > 0 else { return nil }
        var buf = [CChar](repeating: 0, count: 4096)
        guard proc_pidpath(pid, &buf, UInt32(buf.count)) > 0 else { return nil }
        let path = buf.withUnsafeBufferPointer { String(cString: $0.baseAddress!) }
        return path.isEmpty ? nil : path
    }

    /// `pid`'s argv via `KERN_PROCARGS2`. The buffer is `argc` (Int32), the executable path, NUL
    /// padding, exactly `argc` NUL-terminated arguments — and then the whole environment, so only
    /// `argc` runs are read after the path.
    public static func arguments(_ pid: pid_t) -> [String]? {
        guard pid > 0 else { return nil }
        var mib: [Int32] = [CTL_KERN, KERN_PROCARGS2, pid]
        var size = 0
        guard sysctl(&mib, 3, nil, &size, nil, 0) == 0, size > 0 else { return nil }
        var buf = [UInt8](repeating: 0, count: size)
        guard sysctl(&mib, 3, &buf, &size, nil, 0) == 0, size > MemoryLayout<Int32>.size else { return nil }
        let bytes = Array(buf.prefix(size))
        let argc = Int(bytes.withUnsafeBytes { $0.loadUnaligned(as: Int32.self) })
        var i = MemoryLayout<Int32>.size
        while i < bytes.count, bytes[i] != 0 { i += 1 }  // the executable path
        while i < bytes.count, bytes[i] == 0 { i += 1 }  // its padding
        var args: [String] = []
        while args.count < argc, i < bytes.count {
            let start = i
            while i < bytes.count, bytes[i] != 0 { i += 1 }
            args.append(String(decoding: bytes[start..<i], as: UTF8.self))
            i += 1
        }
        return args.isEmpty ? nil : args
    }

    /// `pid`'s current working directory via `PROC_PIDVNODEPATHINFO`.
    public static func workingDirectory(_ pid: pid_t) -> URL? {
        guard pid > 0 else { return nil }
        var info = proc_vnodepathinfo()
        let size = Int32(MemoryLayout<proc_vnodepathinfo>.size)
        guard proc_pidinfo(pid, PROC_PIDVNODEPATHINFO, 0, &info, size) > 0 else { return nil }
        let path = withUnsafeBytes(of: info.pvi_cdir.vip_path) { raw in
            String(decoding: raw.prefix(while: { $0 != 0 }), as: UTF8.self)
        }
        return path.isEmpty ? nil : URL(fileURLWithPath: path, isDirectory: true)
    }

    /// `pid`'s parent via `PROC_PIDTBSDINFO`.
    public static func parent(_ pid: pid_t) -> pid_t? {
        guard pid > 0 else { return nil }
        var info = proc_bsdinfo()
        let size = Int32(MemoryLayout<proc_bsdinfo>.size)
        guard proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &info, size) == size else { return nil }
        return pid_t(info.pbi_ppid)
    }
}
