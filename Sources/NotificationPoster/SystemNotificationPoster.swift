//
//  SystemNotificationPoster.swift
//  NotificationPoster
//
//  Notices through Notification Center.
//
//  Created by David Sherlock on 9/27/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation
import UserNotifications

/// Posts through `UNUserNotificationCenter`, asking for permission the first time. Silent on
/// every failure path — authorisation denied, or a process with no bundle identity (a bare
/// binary), where the notification center raises an exception that cannot be caught.
public struct SystemNotificationPoster: NotificationPosting {
    public init() {}

    public func post(_ notice: Notice) {
        guard Bundle.main.bundleIdentifier != nil else { return }
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            guard granted else { return }
            center.add(Self.request(for: notice), withCompletionHandler: nil)
        }
    }

    /// The request `post` hands the notification center.
    static func request(for notice: Notice) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = notice.title
        content.body = notice.body
        if notice.playsSound { content.sound = .default }
        return UNNotificationRequest(identifier: notice.identifier, content: content, trigger: nil)
    }
}
