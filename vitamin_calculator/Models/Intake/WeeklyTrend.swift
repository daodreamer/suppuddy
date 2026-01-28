//
//  WeeklyTrend.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation

/// Represents a weekly trend analysis of nutrient intake.
/// Aggregates daily summaries and provides trend calculations and chart data.
struct WeeklyTrend {
    // MARK: - Properties

    /// Start date of the trend period
    let startDate: Date

    /// End date of the trend period
    let endDate: Date

    /// Daily summaries for the trend period
    let dailySummaries: [DailyIntakeSummary]

    // MARK: - Computed Properties

    /// Number of days in this trend period
    var dayCount: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }

    // MARK: - Public Methods

    /// Calculates the average daily intake of a specific nutrient
    /// - Parameter nutrientType: The type of nutrient to calculate
    /// - Returns: Average daily intake amount, or 0 if no data
    func averageIntake(for nutrientType: NutrientType) -> Double {
        guard !dailySummaries.isEmpty else { return 0 }

        let totalIntake = dailySummaries.reduce(0.0) { sum, summary in
            sum + summary.totalAmount(for: nutrientType)
        }

        return totalIntake / Double(dailySummaries.count)
    }

    /// Determines the trend direction for a specific nutrient
    /// - Parameter nutrientType: The type of nutrient to analyze
    /// - Returns: The trend direction (increasing, decreasing, or stable)
    func trend(for nutrientType: NutrientType) -> Trend {
        let sortedSummaries = dailySummaries.sorted { $0.date < $1.date }
        guard sortedSummaries.count >= 2 else { return .stable }

        // Compare first half average with second half average
        let midPoint = sortedSummaries.count / 2
        let firstHalf = Array(sortedSummaries.prefix(midPoint))
        let secondHalf = Array(sortedSummaries.suffix(from: midPoint))

        let firstHalfAvg = firstHalf.isEmpty ? 0 : firstHalf.reduce(0.0) { sum, s in
            sum + s.totalAmount(for: nutrientType)
        } / Double(firstHalf.count)

        let secondHalfAvg = secondHalf.isEmpty ? 0 : secondHalf.reduce(0.0) { sum, s in
            sum + s.totalAmount(for: nutrientType)
        } / Double(secondHalf.count)

        // Use 10% threshold to determine significant change
        let threshold = max(firstHalfAvg, secondHalfAvg) * 0.1

        if secondHalfAvg > firstHalfAvg + threshold {
            return .increasing
        } else if secondHalfAvg < firstHalfAvg - threshold {
            return .decreasing
        } else {
            return .stable
        }
    }

    /// Generates data points for chart visualization
    /// - Parameter nutrientType: The type of nutrient to get data for
    /// - Returns: Array of data points sorted by date
    func dataPoints(for nutrientType: NutrientType) -> [DataPoint] {
        dailySummaries
            .sorted { $0.date < $1.date }
            .map { summary in
                DataPoint(
                    date: summary.date,
                    value: summary.totalAmount(for: nutrientType)
                )
            }
    }
}
