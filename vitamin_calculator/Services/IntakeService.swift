//
//  IntakeService.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation

/// Type of health tip to categorize recommendations
enum TipType: String, CaseIterable, Codable, Hashable, Sendable {
    /// Warning for potentially dangerous intake (e.g., exceeding upper limit)
    case warning
    /// Suggestion for improving intake (e.g., insufficient nutrients)
    case suggestion
    /// General informational tip
    case info
}

/// Represents a health tip or recommendation based on nutrient intake
struct HealthTip: Hashable, Sendable {
    /// The type of tip (warning, suggestion, info)
    let type: TipType

    /// The nutrient this tip relates to (nil for general tips)
    let nutrient: NutrientType?

    /// The human-readable message for this tip
    let message: String
}

/// Service for managing supplement intake recording and analysis.
/// Provides business logic for creating intake records, generating summaries, and health recommendations.
final class IntakeService {

    // MARK: - Record Intake

    /// Creates a new intake record for a supplement
    /// - Parameters:
    ///   - supplement: The supplement being taken
    ///   - servings: Number of servings taken
    ///   - timeOfDay: When the supplement was taken
    ///   - date: The date of intake
    /// - Returns: A new IntakeRecord with snapshot of supplement data
    func recordIntake(
        supplement: Supplement,
        servings: Int,
        timeOfDay: TimeOfDay,
        date: Date
    ) -> IntakeRecord {
        IntakeRecord(
            supplement: supplement,
            supplementName: supplement.name,
            date: date,
            timeOfDay: timeOfDay,
            servingsTaken: servings,
            nutrients: supplement.nutrients
        )
    }

    // MARK: - Daily Summary

    /// Generates a daily intake summary for a specific date
    /// - Parameters:
    ///   - date: The date to summarize
    ///   - records: All available intake records
    ///   - user: The user profile for recommendation comparison
    /// - Returns: A DailyIntakeSummary for the specified date
    func getDailySummary(
        for date: Date,
        records: [IntakeRecord],
        user: UserProfile
    ) -> DailyIntakeSummary {
        let calendar = Calendar.current
        let filteredRecords = records.filter { record in
            calendar.isDate(record.date, inSameDayAs: date)
        }

        return DailyIntakeSummary(date: date, records: filteredRecords)
    }

    // MARK: - Weekly Trend

    /// Generates a weekly trend analysis ending on the specified date
    /// - Parameters:
    ///   - date: The end date of the week
    ///   - records: All available intake records
    /// - Returns: A WeeklyTrend with daily summaries for the past 7 days
    func getWeeklyTrend(
        endingOn date: Date,
        records: [IntakeRecord]
    ) -> WeeklyTrend {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -6, to: date)!

        // Group records by date
        var dailySummaries: [DailyIntakeSummary] = []

        for dayOffset in 0..<7 {
            let currentDate = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!
            let dayRecords = records.filter { record in
                calendar.isDate(record.date, inSameDayAs: currentDate)
            }
            let summary = DailyIntakeSummary(date: currentDate, records: dayRecords)
            dailySummaries.append(summary)
        }

        return WeeklyTrend(
            startDate: startDate,
            endDate: date,
            dailySummaries: dailySummaries
        )
    }

    // MARK: - Nutrient Analysis

    /// Identifies nutrients that are below the recommended intake threshold (80%)
    /// - Parameters:
    ///   - summary: The daily intake summary to analyze
    ///   - user: The user profile for recommendation lookup
    /// - Returns: Array of nutrient types that are insufficient
    func getMissingNutrients(
        summary: DailyIntakeSummary,
        user: UserProfile
    ) -> [NutrientType] {
        summary.coveredNutrients.filter { nutrientType in
            summary.status(for: nutrientType, userType: user.userType) == .insufficient
        }
    }

    /// Identifies nutrients that exceed the safe upper limit
    /// - Parameters:
    ///   - summary: The daily intake summary to analyze
    ///   - user: The user profile for recommendation lookup
    /// - Returns: Array of nutrient types that are excessive
    func getExcessiveNutrients(
        summary: DailyIntakeSummary,
        user: UserProfile
    ) -> [NutrientType] {
        summary.coveredNutrients.filter { nutrientType in
            summary.status(for: nutrientType, userType: user.userType) == .excessive
        }
    }

    // MARK: - Health Tips

    /// Generates health tips based on the daily intake summary
    /// - Parameters:
    ///   - summary: The daily intake summary to analyze
    ///   - user: The user profile for recommendation lookup
    /// - Returns: Array of health tips and recommendations
    func generateHealthTips(
        summary: DailyIntakeSummary,
        user: UserProfile
    ) -> [HealthTip] {
        var tips: [HealthTip] = []

        // Generate warnings for excessive nutrients
        let excessiveNutrients = getExcessiveNutrients(summary: summary, user: user)
        for nutrient in excessiveNutrients {
            tips.append(HealthTip(
                type: .warning,
                nutrient: nutrient,
                message: "\(nutrient.localizedName)摄入量超过安全上限，请注意减少摄入"
            ))
        }

        // Generate suggestions for insufficient nutrients
        let missingNutrients = getMissingNutrients(summary: summary, user: user)
        for nutrient in missingNutrients {
            tips.append(HealthTip(
                type: .suggestion,
                nutrient: nutrient,
                message: "\(nutrient.localizedName)摄入不足，建议增加摄入"
            ))
        }

        return tips
    }
}
