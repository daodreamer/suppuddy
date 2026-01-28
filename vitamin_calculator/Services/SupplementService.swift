//
//  SupplementService.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation

/// Represents the comparison of a nutrient's current intake against DGE recommendations.
struct NutrientComparison: Equatable, Sendable {
    /// The type of nutrient being compared
    let nutrientType: NutrientType

    /// Current daily intake amount
    let currentAmount: Double

    /// DGE recommended daily amount
    let recommendedAmount: Double

    /// Upper safe limit (optional)
    let upperLimit: Double?

    /// Percentage of recommended amount (currentAmount / recommendedAmount * 100)
    let percentage: Double

    /// Status indicating if intake is insufficient, normal, or excessive
    let status: NutrientStatus
}

/// Validation errors for supplement data
enum SupplementValidationError: String, CaseIterable, Equatable {
    case emptyName
    case emptyServingSize
    case invalidServingsPerDay
}

/// Service for supplement-related business logic calculations and validations.
final class SupplementService {

    // MARK: - Initialization

    init() {}

    // MARK: - Total Nutrients Calculation

    /// Calculates the total daily intake of all nutrients from active supplements
    /// - Parameter supplements: Array of supplements to calculate totals from
    /// - Returns: Dictionary mapping nutrient types to their total daily amounts
    func calculateTotalNutrients(from supplements: [Supplement]) -> [NutrientType: Double] {
        var totals: [NutrientType: Double] = [:]

        for supplement in supplements where supplement.isActive {
            let dailyAmounts = supplement.allNutrientsDailyAmounts()
            for (nutrientType, amount) in dailyAmounts {
                totals[nutrientType, default: 0] += amount
            }
        }

        return totals
    }

    // MARK: - Comparison with Recommendations

    /// Compares supplement nutrient totals with DGE recommendations for a user
    /// - Parameters:
    ///   - supplements: Array of supplements to analyze
    ///   - user: User profile for personalized recommendations
    /// - Returns: Array of NutrientComparison objects for nutrients in the supplements
    func compareWithRecommendations(
        supplements: [Supplement],
        user: UserProfile
    ) -> [NutrientComparison] {
        let totals = calculateTotalNutrients(from: supplements)
        var comparisons: [NutrientComparison] = []

        for (nutrientType, currentAmount) in totals {
            guard let recommendation = DGERecommendations.getRecommendation(
                for: nutrientType,
                userType: user.userType
            ) else { continue }

            let percentage = (currentAmount / recommendation.recommendedAmount) * 100
            let status = determineStatus(
                currentAmount: currentAmount,
                recommendedAmount: recommendation.recommendedAmount,
                upperLimit: recommendation.upperLimit
            )

            let comparison = NutrientComparison(
                nutrientType: nutrientType,
                currentAmount: currentAmount,
                recommendedAmount: recommendation.recommendedAmount,
                upperLimit: recommendation.upperLimit,
                percentage: percentage,
                status: status
            )

            comparisons.append(comparison)
        }

        return comparisons
    }

    // MARK: - Validation

    /// Validates a supplement and returns any validation errors
    /// - Parameter supplement: The supplement to validate
    /// - Returns: Array of validation errors (empty if valid)
    func validateSupplement(_ supplement: Supplement) -> [SupplementValidationError] {
        var errors: [SupplementValidationError] = []

        if supplement.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.emptyName)
        }

        if supplement.servingSize.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.emptyServingSize)
        }

        if supplement.servingsPerDay <= 0 {
            errors.append(.invalidServingsPerDay)
        }

        return errors
    }

    // MARK: - Missing Nutrients

    /// Identifies nutrients that are not present in any of the user's active supplements
    /// - Parameters:
    ///   - supplements: Array of supplements to analyze
    ///   - user: User profile for context
    /// - Returns: Array of NutrientType that are missing from the supplements
    func getMissingNutrients(
        supplements: [Supplement],
        user: UserProfile
    ) -> [NutrientType] {
        let presentNutrients = Set(calculateTotalNutrients(from: supplements).keys)
        let allNutrients = Set(NutrientType.allCases)

        return Array(allNutrients.subtracting(presentNutrients))
    }

    // MARK: - Private Helpers

    private func determineStatus(
        currentAmount: Double,
        recommendedAmount: Double,
        upperLimit: Double?
    ) -> NutrientStatus {
        // Check if exceeds upper limit
        if let limit = upperLimit, currentAmount > limit {
            return .excessive
        }

        // Check if below 80% of recommended
        let percentage = (currentAmount / recommendedAmount) * 100
        if percentage < 80 {
            return .insufficient
        }

        return .normal
    }
}
