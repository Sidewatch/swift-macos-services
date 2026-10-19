//
//  AdministratorShell.swift
//  CommandLineTool
//
//  One shell command run with administrator privileges, behind the system's own password prompt.
//
//  Created by David Sherlock on 10/20/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

/// One shell command run with administrator privileges, through AppleScript's `do shell script …
/// with administrator privileges`: macOS shows its own password prompt, and the app never sees the
/// password. For an unsandboxed app; a sandboxed one is refused.
public enum AdministratorShell {
    /// Runs `command` as an administrator; false when the person cancels the prompt or the command
    /// fails. Blocks while the prompt is up.
    @MainActor public static func run(_ command: String) -> Bool {
        var error: NSDictionary?
        _ = NSAppleScript(source: appleScript(for: command))?.executeAndReturnError(&error)
        return error == nil
    }

    /// `text` as one POSIX shell word: single-quoted, each `'` written as `'\''`.
    public static func quoted(_ text: String) -> String {
        "'" + text.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    /// The AppleScript that runs `command`: the command as an AppleScript string literal, so a
    /// `"` or `\` in a path cannot end the literal early.
    static func appleScript(for command: String) -> String {
        let literal = command.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        return "do shell script \"\(literal)\" with administrator privileges"
    }
}
