//
//  Trend.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation

/// Represents the direction of a nutrient intake trend over time.
enum Trend: String, CaseIterable, Codable, Hashable, Sendable {
    case increasing
    case decreasing
    case stable

    /// Localized display name for the trend
    var displayName: String {
        switch self {
        case .increasing:
            return "上升"
        case .decreasing:
            return "下降"
        case .stable:
            return "稳定"
        }
    }
}

/// Represents a single data point for chart visualization.
struct DataPoint: Hashable, Sendable {
    /// The date of this data point
    let date: Date

    /// The value at this date
    let value: Double
}
