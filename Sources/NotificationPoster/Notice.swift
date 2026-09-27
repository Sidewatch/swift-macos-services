//
//  Notice.swift
//  NotificationPoster
//
//  One notification: what it says and whether it sounds.
//
//  Created by David Sherlock on 9/27/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

/// One notification to show: its text, the identifier that lets a later one replace it, and
/// whether it plays the alert sound.
public struct Notice: Equatable, Sendable {
    /// The bold first line.
    public let title: String
    /// The text under the title.
    public let body: String
    /// A later notice with the same identifier replaces this one in Notification Center.
    public let identifier: String
    /// Whether the default alert sound plays with it.
    public let playsSound: Bool

    /// A notice with a fresh identifier (so it never replaces another) unless one is given.
    public init(title: String, body: String, identifier: String = UUID().uuidString, playsSound: Bool = true) {
        self.title = title
        self.body = body
        self.identifier = identifier
        self.playsSound = playsSound
    }
}
