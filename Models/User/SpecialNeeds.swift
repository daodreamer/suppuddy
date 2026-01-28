//
//  SpecialNeeds.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 1.1
//

import Foundation

/// Represents special nutritional needs for personalized recommendations.
/// Based on German DGE (Deutsche Gesellschaft für Ernährung) standards.
enum SpecialNeeds: String, Codable, CaseIterable, Sendable {
    /// No special needs
    case none = "无"

    /// Pregnancy period - requires additional nutrients
    case pregnant = "孕期"

    /// Breastfeeding period - requires additional nutrients
    case breastfeeding = "哺乳期"

    /// Both pregnancy and breastfeeding - combined special needs
    case pregnantAndBreastfeeding = "孕期及哺乳期"
}
