//
//  NutrientStatus.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation

/// Represents the intake status of a nutrient relative to daily recommendations.
/// Based on DGE guidelines for nutrient intake assessment.
enum NutrientStatus: String, CaseIterable, Codable, Hashable, Sendable {
    /// No intake or nutrient not present in supplement
    case none

    /// Intake is below 80% of recommended daily amount
    case insufficient

    /// Intake is within normal range (80% to upper limit)
    case normal

    /// Intake exceeds the safe upper limit
    case excessive
}
