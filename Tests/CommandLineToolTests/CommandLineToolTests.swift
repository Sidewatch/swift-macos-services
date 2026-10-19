//
//  CommandLineToolTests.swift
//  CommandLineToolTests
//
//  Tests for `CommandLineTool` against real folders: the four states, install and uninstall as
//  the person, and the administrator fallback when the folder is not theirs to write.
//
//  Created by David Sherlock on 10/20/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import XCTest
@testable import CommandLineTool

/// Tests for `CommandLineTool` against real folders: the four states, install and uninstall as
/// the person, and the administrator fallback when the folder is not theirs to write.
@MainActor final class CommandLineToolTests: XCTestCase {
    private var root: URL!
    private var source: URL!
    private var bin: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("clt-\(UUID().uuidString)")
        bin = root.appendingPathComponent("bin")
        source = root.appendingPathComponent("App.app/Contents/Resources/bin/tool")
        try FileManager.default.createDirectory(at: source.deletingLastPathComponent(), withIntermediateDirectories: true)
        try "#!/bin/sh\n".write(to: source, atomically: true, encoding: .utf8)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: bin.path)
        try? FileManager.default.removeItem(at: root)
    }

    private func tool(
        _ runner: @escaping CommandLineTool.PrivilegedRunner = { _ in
            XCTFail("no prompt expected"); return false
        }
    )
        -> CommandLineTool
    {
        CommandLineTool(name: "tool", source: source, directory: bin, runPrivileged: runner)
    }

    // MARK: - state

    func testNothingThereIsNotInstalled() {
        XCTAssertEqual(tool().state(), .notInstalled)
    }

    func testALinkToAnotherFileIsLinkedElsewhere() throws {
        try FileManager.default.createDirectory(at: bin, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(
            atPath: bin.appendingPathComponent("tool").path, withDestinationPath: "/old/App.app/tool")
        XCTAssertEqual(tool().state(), .linkedElsewhere("/old/App.app/tool"))
    }

    func testARelativeLinkToTheSourceIsInstalled() throws {
        try FileManager.default.createDirectory(at: bin, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(
            atPath: bin.appendingPathComponent("tool").path, withDestinationPath: "../App.app/Contents/Resources/bin/tool")
        XCTAssertEqual(tool().state(), .installed)
    }

    func testAPlainFileIsOccupied() throws {
        try FileManager.default.createDirectory(at: bin, withIntermediateDirectories: true)
        try "x".write(to: bin.appendingPathComponent("tool"), atomically: true, encoding: .utf8)
        XCTAssertEqual(tool().state(), .occupied)
    }

    // MARK: - install / uninstall as the person

    func testInstallCreatesTheFolderAndTheLink() {
        XCTAssertTrue(tool().install())
        XCTAssertEqual(tool().state(), .installed)
    }

    func testInstallReplacesAStaleLink() throws {
        try FileManager.default.createDirectory(at: bin, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(atPath: bin.appendingPathComponent("tool").path, withDestinationPath: "/old/tool")
        XCTAssertTrue(tool().install())
        XCTAssertEqual(tool().state(), .installed)
    }

    func testInstallRefusesAFolderInTheWay() throws {
        try FileManager.default.createDirectory(at: bin.appendingPathComponent("tool"), withIntermediateDirectories: true)
        XCTAssertFalse(tool().install())
        XCTAssertEqual(tool().state(), .occupied)
    }

    func testUninstallRemovesOnlyItsOwnLink() throws {
        XCTAssertTrue(tool().install())
        XCTAssertTrue(tool().uninstall())
        XCTAssertEqual(tool().state(), .notInstalled)

        try FileManager.default.createSymbolicLink(atPath: bin.appendingPathComponent("tool").path, withDestinationPath: "/other/tool")
        XCTAssertTrue(tool().uninstall())
        XCTAssertEqual(tool().state(), .linkedElsewhere("/other/tool"), "another program's tool is left alone")
    }

    // MARK: - the administrator fallback

    func testAFolderThePersonCannotWriteAsksForAnAdministrator() throws {
        try FileManager.default.createDirectory(at: bin, withIntermediateDirectories: true)
        try FileManager.default.setAttributes([.posixPermissions: 0o555], ofItemAtPath: bin.path)
        var asked: [String] = []
        XCTAssertFalse(
            tool {
                asked.append($0); return false
            }.install(), "a cancelled prompt installs nothing")
        XCTAssertEqual(asked.count, 1)
        XCTAssertTrue(asked[0].contains("/bin/ln -sf '\(source.path)' '\(bin.path)/tool'"), asked[0])
    }

    func testQuotingSurvivesASingleQuote() {
        XCTAssertEqual(AdministratorShell.quoted("/Apps/Kim's.app"), "'/Apps/Kim'\\''s.app'")
    }

    func testTheAppleScriptLiteralCannotBeClosedByAPath() {
        XCTAssertEqual(
            AdministratorShell.appleScript(for: #"/bin/rm -f '/a "b" \c'"#),
            #"do shell script "/bin/rm -f '/a \"b\" \\c'" with administrator privileges"#)
    }
}
