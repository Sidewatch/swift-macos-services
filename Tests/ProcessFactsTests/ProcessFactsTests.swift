//
//  ProcessFactsTests.swift
//  ProcessFactsTests
//
//  The readers against real processes: this test process, children it spawns, and sockets it
//  opens itself.
//
//  Created by David Sherlock on 10/13/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Darwin
import XCTest
@testable import ProcessFacts

final class ProcessFactsTests: XCTestCase {

    // MARK: Identity

    func testThisProcessDescribesItself() {
        let me = getpid()
        XCTAssertEqual(ProcessFacts.parent(me), getppid())
        XCTAssertEqual(ProcessFacts.arguments(me), CommandLine.arguments, "argv only, never the environment after it")
        XCTAssertEqual(
            ProcessFacts.workingDirectory(me)?.resolvingSymlinksInPath().path,
            URL(fileURLWithPath: FileManager.default.currentDirectoryPath).resolvingSymlinksInPath().path)
        XCTAssertEqual(
            ProcessFacts.executablePath(me).map { URL(fileURLWithPath: $0).lastPathComponent },
            URL(fileURLWithPath: CommandLine.arguments[0]).lastPathComponent)
        XCTAssertNotNil(ProcessFacts.name(me))
    }

    func testAProcessThatIsGoneHasNoFacts() {
        XCTAssertNil(ProcessFacts.name(0))
        XCTAssertNil(ProcessFacts.parent(-1))
        XCTAssertTrue(ProcessFacts.listeningPorts(0).isEmpty)
        XCTAssertTrue(ProcessFacts.descendants(of: 0).isEmpty)
    }

    // MARK: The tree

    private func spawn(_ path: String, _ args: [String]) throws -> Process {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        p.standardOutput = FileHandle.nullDevice
        p.standardError = FileHandle.nullDevice
        try p.run()
        addTeardownBlock { if p.isRunning { p.terminate(); p.waitUntilExit() } }
        return p
    }

    func testAChildAndAGrandchildAreDescendants() throws {
        let child = try spawn("/bin/sleep", ["30"])
        let shell = try spawn("/bin/sh", ["-c", "/bin/sleep 30 & wait"])
        var grandchild: pid_t?
        let deadline = Date(timeIntervalSinceNow: 3)
        while grandchild == nil, Date() < deadline {
            grandchild = ProcessFacts.descendants(of: shell.processIdentifier).first
            if grandchild == nil { usleep(20_000) }
        }
        let mine = ProcessFacts.descendants(of: getpid())
        XCTAssertTrue(mine.contains(child.processIdentifier), "a direct child")
        XCTAssertTrue(mine.contains(shell.processIdentifier))
        let g = try XCTUnwrap(grandchild, "the shell's own child appears")
        XCTAssertTrue(mine.contains(g), "a grandchild is a descendant too")
        XCTAssertEqual(ProcessFacts.parent(g), shell.processIdentifier)
        XCTAssertFalse(mine.contains(getpid()), "the root itself is not its own descendant")
    }

    // MARK: Ports

    /// A TCP socket bound to `address` on a free port; listening unless `listen` is false.
    private func socket(_ address: String, listening: Bool = true) throws -> (fd: Int32, port: UInt16) {
        let fd = Darwin.socket(AF_INET, SOCK_STREAM, 0)
        XCTAssertGreaterThanOrEqual(fd, 0)
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = 0
        addr.sin_addr.s_addr = inet_addr(address)
        let bound = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { Darwin.bind(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) }
        }
        XCTAssertEqual(bound, 0)
        if listening { XCTAssertEqual(Darwin.listen(fd, 4), 0) }
        var out = sockaddr_in()
        var len = socklen_t(MemoryLayout<sockaddr_in>.size)
        _ = withUnsafeMutablePointer(to: &out) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { Darwin.getsockname(fd, $0, &len) } }
        addTeardownBlock { close(fd) }
        return (fd, UInt16(bigEndian: out.sin_port))
    }

    func testAListeningSocketIsReportedWithItsAddressScope() throws {
        let loopback = try socket("127.0.0.1")
        let everywhere = try socket("0.0.0.0")
        let ports = ProcessFacts.listeningPorts(getpid())
        XCTAssertEqual(ports.first { $0.port == loopback.port }?.isLoopbackOnly, true)
        XCTAssertEqual(ports.first { $0.port == everywhere.port }?.isLoopbackOnly, false)
        XCTAssertTrue(ports.allSatisfy { $0.pid == getpid() })
    }

    func testABoundButNotListeningSocketIsNotAServer() throws {
        let idle = try socket("127.0.0.1", listening: false)
        XCTAssertFalse(ProcessFacts.listeningPorts(getpid()).contains { $0.port == idle.port })
    }

    func testAServerInAChildProcessIsFoundThroughTheTree() throws {
        // A free port, then `nc -l` listening on it in a child — the shape of a dev server an agent
        // left running in a terminal.
        let probe = try socket("127.0.0.1", listening: false)
        close(probe.fd)
        let server = try spawn("/usr/bin/nc", ["-l", "127.0.0.1", String(probe.port)])
        var found: ListeningPort?
        let deadline = Date(timeIntervalSinceNow: 3)
        while found == nil, Date() < deadline {
            found = ProcessFacts.descendants(of: getpid()).flatMap(ProcessFacts.listeningPorts).first { $0.port == probe.port }
            if found == nil { usleep(20_000) }
        }
        let port = try XCTUnwrap(found, "the child's listening port")
        XCTAssertEqual(port.pid, server.processIdentifier)
        XCTAssertEqual(ProcessFacts.name(port.pid), "nc")
    }

    // MARK: Servers

    func testServersUnderRootsAreFoundOncePerPortInPortOrder() throws {
        let sockets = try (0..<6).map { _ in try socket("127.0.0.1") }
        let ports = Set(sockets.map(\.port))
        let parent = getppid()
        let grandparent = try XCTUnwrap(ProcessFacts.parent(parent))
        // Both roots hold this process: the FIRST root keeps each port.
        let found = ProcessFacts.listeningProcesses(under: [parent, grandparent]).filter { ports.contains($0.port) }
        XCTAssertEqual(found.map(\.port), ports.sorted(), "each port once, by port")
        XCTAssertTrue(found.allSatisfy { $0.pid == getpid() && $0.root == parent && !$0.arguments.isEmpty }, "the first root keeps it")
        XCTAssertTrue(
            ProcessFacts.listeningProcesses(under: [getpid()]).filter { ports.contains($0.port) }.isEmpty,
            "a root is not its own descendant")
    }

    func testAServersShortCommandIsItsFirstWordsWithoutPaths() {
        let server = ListeningProcess(port: 5173, pid: 1, arguments: ["node", "/repo/node_modules/.bin/vite", "--port", "5173"], root: 1)
        XCTAssertEqual(server.shortCommand, "node vite --port")
    }
}
