//
//  CommandLineTool.swift
//  CommandLineTool
//
//  A command-line tool shipped inside an app bundle, linked into a folder on the PATH.
//
//  Created by David Sherlock on 10/20/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

/// A command-line tool shipped inside an app bundle, linked into a folder on the PATH
/// (`/usr/local/bin` by default, as VS Code does for `code`). The link points into the bundle, so
/// an app update updates the tool; a moved app leaves a link to the old place, which ``state()``
/// reports as ``CommandLineToolState/linkedElsewhere(_:)``.
///
/// Writing the folder needs an administrator on most Macs: ``install()`` and ``uninstall()`` try
/// as the person first and fall back to `runPrivileged` (the system password prompt by default).
public struct CommandLineTool: Sendable {
    /// Runs one shell command as an administrator; true when it ran and succeeded.
    public typealias PrivilegedRunner = @MainActor (_ shellCommand: String) -> Bool

    /// The command's name, the link's file name.
    public let name: String
    /// The tool inside the bundle.
    public let source: URL
    /// The folder the link goes in.
    public let directory: URL
    private let runPrivileged: PrivilegedRunner

    /// Creates a tool `name` for `source`, linked into `directory`.
    public init(
        name: String, source: URL, directory: URL = URL(fileURLWithPath: "/usr/local/bin"),
        runPrivileged: @escaping PrivilegedRunner = { AdministratorShell.run($0) }
    ) {
        self.name = name
        self.source = source
        self.directory = directory
        self.runPrivileged = runPrivileged
    }

    /// Where the link goes.
    public var linkURL: URL { directory.appendingPathComponent(name) }

    /// What is at ``linkURL`` now. Read fresh each time: the person can change it from a shell.
    public func state() -> CommandLineToolState {
        let fm = FileManager.default
        if let target = try? fm.destinationOfSymbolicLink(atPath: linkURL.path) {
            let absolute = target.hasPrefix("/") ? target : directory.appendingPathComponent(target).path
            return URL(fileURLWithPath: absolute).standardizedFileURL.path == source.standardizedFileURL.path
                ? .installed : .linkedElsewhere(absolute)
        }
        return fm.fileExists(atPath: linkURL.path) ? .occupied : .notInstalled
    }

    /// Links ``linkURL`` to ``source``, replacing a link or a file already there (the host asks
    /// first). Refuses a folder there. True when the link is in place afterwards.
    @MainActor public func install() -> Bool {
        var isDirectory: ObjCBool = false
        if state() == .occupied, FileManager.default.fileExists(atPath: linkURL.path, isDirectory: &isDirectory),
            isDirectory.boolValue
        {
            return false
        }
        if (try? linkDirectly()) == nil {
            let command =
                "/bin/mkdir -p \(AdministratorShell.quoted(directory.path)) && "
                + "/bin/ln -sf \(AdministratorShell.quoted(source.path)) \(AdministratorShell.quoted(linkURL.path))"
            guard runPrivileged(command) else { return false }
        }
        return state() == .installed
    }

    /// Removes the link when it is this tool's; anything else is left alone. True when nothing of
    /// this tool's is there afterwards.
    @MainActor public func uninstall() -> Bool {
        guard state() == .installed else { return true }
        if (try? FileManager.default.removeItem(at: linkURL)) == nil {
            guard runPrivileged("/bin/rm -f \(AdministratorShell.quoted(linkURL.path))") else { return false }
        }
        return state() != .installed
    }

    /// The link made as the person: the folder created if missing, anything at the link removed
    /// first. Throws when the folder is not theirs to write.
    private func linkDirectly() throws {
        let fm = FileManager.default
        try fm.createDirectory(at: directory, withIntermediateDirectories: true)
        if state() != .notInstalled { try fm.removeItem(at: linkURL) }
        try fm.createSymbolicLink(at: linkURL, withDestinationURL: source)
    }
}
