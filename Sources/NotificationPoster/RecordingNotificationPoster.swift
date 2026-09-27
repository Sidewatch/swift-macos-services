//
//  RecordingNotificationPoster.swift
//  NotificationPoster
//
//  A poster that keeps what it was asked to show, for tests.
//
//  Created by David Sherlock on 9/27/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

/// Keeps every ``Notice`` it is asked to post, in order, and shows nothing — the stand-in a test
/// or a self-check passes where the app would pass ``SystemNotificationPoster``.
public final class RecordingNotificationPoster: NotificationPosting, @unchecked Sendable {
    private let lock = NSLock()
    private var notices: [Notice] = []

    /// An empty recorder.
    public init() {}

    /// Everything posted so far, oldest first.
    public var posted: [Notice] { lock.lock(); defer { lock.unlock() }; return notices }

    /// Records `notice`; nothing is shown.
    public func post(_ notice: Notice) { lock.lock(); notices.append(notice); lock.unlock() }

    /// Forgets what was posted.
    public func clear() { lock.lock(); notices.removeAll(); lock.unlock() }
}
