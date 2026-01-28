//
//  DailyIntakeSummary.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation

/// Represents a summary of daily nutrient intake from all recorded supplements.
/// Aggregates data from multiple IntakeRecords and provides comparison with DGE recommendations.
struct DailyIntakeSummary {
    // MARK: - Properties

    /// The date this summary represents
    let date: Date

    /// All intake records for this day
    let records: [IntakeRecord]

    // MARK: - Computed Properties

    /// Total nutrients aggregated from all records
    /// Key: NutrientType, Value: Total amount (sum of all records × their servings)
    var totalNutrients: [NutrientType: Double] {
        var totals: [NutrientType: Double] = [:]

        for record in records {
            let recordTotals = record.allNutrientsTotalAmounts()
            for (nutrientType, amount) in recordTotals {
                totals[nutrientType, default: 0] += amount
            }
        }

        return totals
    }

    /// Number of intake records for this day
    var recordCount: Int {
        records.count
    }

    /// Set of all nutrient types that have been recorded today
    var coveredNutrients: Set<NutrientType> {
        Set(totalNutrients.keys)
    }

    // MARK: - Public Methods

    /// Returns the total amount of a specific nutrient for the day
    /// - Parameter nutrientType: The type of nutrient to get
    /// - Returns: Total amount, or 0 if nutrient not present in any record
    func totalAmount(for nutrientType: NutrientType) -> Double {
        totalNutrients[nutrientType] ?? 0
    }

    /// Calculates the completion percentage for a nutrient based on DGE recommendations
    /// - Parameters:
    ///   - nutrientType: The type of nutrient to calculate
    ///   - userType: The user's demographic type for recommendation lookup
    /// - Returns: Percentage of daily recommendation achieved (0-100+)
    func completionPercentage(for nutrientType: NutrientType, userType: UserType) -> Double {
        let intake = totalAmount(for: nutrientType)
        guard intake > 0 else { return 0 }

        guard let recommendation = DGERecommendations.getRecommendation(
            for: nutrientType,
            userType: userType
        ) else {
            return 0
        }

        return (intake / recommendation.recommendedAmount) * 100
    }

    /// Determines the intake status of a nutrient based on DGE recommendations
    /// - Parameters:
    ///   - nutrientType: The type of nutrient to evaluate
    ///   - userType: The user's demographic type for recommendation lookup
    /// - Returns: The nutrient status (none, insufficient, normal, or excessive)
    func status(for nutrientType: NutrientType, userType: UserType) -> NutrientStatus {
        let intake = totalAmount(for: nutrientType)
        guard intake > 0 else { return .none }

        guard let recommendation = DGERecommendations.getRecommendation(
            for: nutrientType,
            userType: userType
        ) else {
            return .none
        }

        let percentage = (intake / recommendation.recommendedAmount) * 100

        // Check if exceeds upper limit (if defined)
        if let upperLimit = recommendation.upperLimit, intake > upperLimit {
            return .excessive
        }

        // Check if below 80% of recommended
        if percentage < 80 {
            return .insufficient
        }

        return .normal
    }

    /// Returns all supplements that contributed to a specific nutrient's intake
    /// - Parameter nutrientType: The type of nutrient to analyze
    /// - Returns: Array of tuples containing supplement name and amount contributed
    func nutrientSources(for nutrientType: NutrientType) -> [(supplementName: String, amount: Double)] {
        var sources: [(supplementName: String, amount: Double)] = []

        for record in records {
            let amount = record.totalAmount(for: nutrientType)
            if amount > 0 {
                sources.append((supplementName: record.supplementName, amount: amount))
            }
        }

        return sources
    }
}
