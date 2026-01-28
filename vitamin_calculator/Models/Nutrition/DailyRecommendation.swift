//
//  DailyRecommendation.swift
//  vitamin_calculator
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Foundation

/// Represents the daily recommended intake for a specific nutrient and user type.
/// Based on German DGE (Deutsche Gesellschaft für Ernährung) standards.
struct DailyRecommendation: Codable, Hashable, Sendable {
    // MARK: - Properties

    /// The type of nutrient this recommendation is for
    let nutrientType: NutrientType

    /// The recommended daily amount in the nutrient's standard unit (mg or μg)
    let recommendedAmount: Double

    /// The upper safe limit for daily intake (tolerable upper intake level)
    /// Some nutrients may not have an established upper limit
    let upperLimit: Double?

    /// The user demographic type this recommendation applies to
    let userType: UserType

    // MARK: - Initialization

    /// Creates a daily recommendation for a nutrient
    /// - Parameters:
    ///   - nutrientType: The type of nutrient
    ///   - recommendedAmount: The recommended daily amount
    ///   - upperLimit: The maximum safe daily amount (optional)
    ///   - userType: The user demographic type
    init(
        nutrientType: NutrientType,
        recommendedAmount: Double,
        upperLimit: Double? = nil,
        userType: UserType
    ) {
        self.nutrientType = nutrientType
        self.recommendedAmount = recommendedAmount
        self.upperLimit = upperLimit
        self.userType = userType
    }
}
