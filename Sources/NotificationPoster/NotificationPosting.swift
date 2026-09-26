//
//  NotificationPosting.swift
//  NotificationPoster
//
//  Anything that can show a notification.
//
//  Created by David Sherlock on 9/27/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

/// Anything that can show a ``Notice``: Notification Center in the app, a recorder in a test.
/// A host holds one of these instead of calling the system directly, so its logic can be
/// exercised without a notification ever reaching the screen.
public protocol NotificationPosting: Sendable {
    /// Shows `notice`, or does nothing when notifications are unavailable or not allowed.
    func post(_ notice: Notice)
}
