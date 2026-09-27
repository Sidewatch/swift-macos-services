//
//  NotificationPosterTests.swift
//  NotificationPosterTests
//
//  The request handed to Notification Center carries the notice's text, identity and sound;
//  the recorder keeps notices in order.
//
//  Created by David Sherlock on 9/27/26.
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import XCTest
@testable import NotificationPoster

final class NotificationPosterTests: XCTestCase {
    func testTheRequestCarriesTextIdentityAndSound() {
        let r = SystemNotificationPoster.request(for: Notice(title: "Needs you", body: "Allow edit?", identifier: "pane-1"))
        XCTAssertEqual(r.identifier, "pane-1")
        XCTAssertEqual(r.content.title, "Needs you")
        XCTAssertEqual(r.content.body, "Allow edit?")
        XCTAssertNotNil(r.content.sound)
        XCTAssertNil(r.trigger, "delivered now")
    }

    func testASilentNoticeHasNoSound() {
        XCTAssertNil(SystemNotificationPoster.request(for: Notice(title: "t", body: "b", playsSound: false)).content.sound)
    }

    func testTheRecorderKeepsNoticesInOrderAndClears() {
        let rec = RecordingNotificationPoster()
        rec.post(Notice(title: "a", body: ""))
        rec.post(Notice(title: "b", body: ""))
        XCTAssertEqual(rec.posted.map(\.title), ["a", "b"])
        rec.clear()
        XCTAssertTrue(rec.posted.isEmpty)
    }
}
