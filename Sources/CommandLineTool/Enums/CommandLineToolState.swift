//
//  CommandLineToolState.swift
//  CommandLineTool
//
//  What sits where a command-line tool's link would go.
//
//  Created by David Sherlock on 10/20/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

/// What sits where a command-line tool's link would go.
public enum CommandLineToolState: Equatable, Sendable {
    /// Nothing is there.
    case notInstalled
    /// A link to this tool's source.
    case installed
    /// A link to another file: an older copy of the app, or another program's tool of that name.
    case linkedElsewhere(String)
    /// A file or folder that is not a link.
    case occupied
}
