//
//  NoticeText.swift
//  NotificationPoster
//
//  Text fit to show in Notification Center, whoever wrote it.
//
//  Copyright © 2026 ArrayPress Limited. MIT licence.
//

import Foundation

/// Makes a notice's text safe to show. A title or body can come from a program running in a
/// terminal (an OSC 777 notification, a prompt scraped off its screen), so it is held to what a
/// person can read: control characters go, the Unicode controls that reorder or hide text go
/// (zero-width and bidi marks, embeddings, overrides, isolates), and a title or body past its
/// cap is cut with an ellipsis.
public enum NoticeText {
    /// The longest title shown.
    public static let titleCap = 256
    /// The longest body shown.
    public static let bodyCap = 2_000

    /// The code points removed: C0 and C1 controls except a line feed and a tab, DEL, and
    /// U+200B–U+200F, U+202A–U+202E, U+2066–U+2069.
    public static func isRemoved(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x0A, 0x09: return false
        case 0x00...0x1F, 0x7F...0x9F: return true
        case 0x200B...0x200F, 0x202A...0x202E, 0x2066...0x2069: return true
        default: return false
        }
    }

    /// `text` without the removed code points, cut to `cap` characters (the last one an
    /// ellipsis when it was cut).
    public static func sanitized(_ text: String, cap: Int) -> String {
        let kept = String(String.UnicodeScalarView(text.unicodeScalars.filter { !isRemoved($0) }))
        guard kept.count > cap else { return kept }
        return String(kept.prefix(max(cap - 1, 0))) + "…"
    }

    /// A title: sanitised, line feeds and tabs as spaces, at most ``titleCap`` characters.
    public static func title(_ text: String) -> String {
        sanitized(text.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "\t", with: " "), cap: titleCap)
    }

    /// A body: sanitised, at most ``bodyCap`` characters.
    public static func body(_ text: String) -> String { sanitized(text, cap: bodyCap) }
}
