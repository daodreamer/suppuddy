//
//  Nutrient.swift
//  vitamin_calculator
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Foundation

/// Represents a specific nutrient with its type and amount.
/// Used to track individual nutrients in supplements and calculate total intake.
struct Nutrient: Codable, Hashable, Sendable {
    // MARK: - Properties

    /// The type of nutrient (e.g., Vitamin C, Calcium)
    let type: NutrientType

    /// The amount of the nutrient in its standard unit
    /// For vitamins measured in μg (micrograms) or mg (milligrams)
    let amount: Double

    // MARK: - Initialization

    /// Creates a new nutrient with the specified type and amount
    /// - Parameters:
    ///   - type: The type of nutrient
    ///   - amount: The amount of the nutrient in its standard unit (μg or mg)
    init(type: NutrientType, amount: Double) {
        self.type = type
        self.amount = amount
    }
}
