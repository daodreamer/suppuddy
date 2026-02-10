//
//  TimeOfDay.swift
//  suppuddy
//
//  Created by Claude Code on 26.01.26.
//

import Foundation

/// Represents the time of day when a supplement is taken.
/// Used to categorize intake records and provide more specific tracking.
enum TimeOfDay: String, CaseIterable, Codable, Hashable, Sendable {
    case morning
    case noon
    case evening
    case night

    /// Localized display name for the time of day
    var displayName: String {
        switch self {
        case .morning:
            return String(localized: "早晨")
        case .noon:
            return String(localized: "中午")
        case .evening:
            return String(localized: "傍晚")
        case .night:
            return String(localized: "晚上")
        }
    }
}
