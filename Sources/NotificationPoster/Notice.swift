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
    public let title: String
    public let body: String
    public let identifier: String
    public let playsSound: Bool

    public init(title: String, body: String, identifier: String = UUID().uuidString, playsSound: Bool = true) {
        self.title = title
        self.body = body
        self.identifier = identifier
        self.playsSound = playsSound
    }
}
