//
//  NoticeTextTests.swift
//  NotificationPosterTests
//
//  A program's text reaches Notification Center without controls, reordering marks or excess.
//
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import XCTest
@testable import NotificationPoster

final class NoticeTextTests: XCTestCase {
    func testControlsAndBidiMarksAreRemoved() {
        let hostile = "Build\u{07} \u{1B}[31mfailed\u{202E}dellac\u{202C} \u{200B}now\u{2066}!\u{2069}\u{00}\u{9B}"
        XCTAssertEqual(NoticeText.sanitized(hostile, cap: 256), "Build [31mfaileddellac now!")
        XCTAssertEqual(NoticeText.sanitized("line\ttwo\nthree", cap: 256), "line\ttwo\nthree", "a body keeps its tabs and line feeds")
        XCTAssertEqual(NoticeText.title("line\ttwo\nthree"), "line two three", "a title is one line")
    }

    func testTheCapsCutWithAnEllipsis() {
        let long = String(repeating: "a", count: 300)
        XCTAssertEqual(NoticeText.title(long).count, NoticeText.titleCap)
        XCTAssertTrue(NoticeText.title(long).hasSuffix("…"))
        XCTAssertEqual(NoticeText.body(String(repeating: "b", count: 5_000)).count, NoticeText.bodyCap)
        XCTAssertEqual(NoticeText.body("short"), "short")
        XCTAssertEqual(NoticeText.sanitized("exact", cap: 5), "exact", "at the cap nothing is cut")
    }

    func testTheRequestCarriesTheSanitisedText() {
        let request = SystemNotificationPoster.request(for: Notice(title: "T\u{202E}itle", body: "B\u{07}ody\u{200B}"))
        XCTAssertEqual(request.content.title, "Title")
        XCTAssertEqual(request.content.body, "Body")
    }
}
