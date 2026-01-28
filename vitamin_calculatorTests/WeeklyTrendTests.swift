//
//  WeeklyTrendTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("WeeklyTrend Tests")
struct WeeklyTrendTests {

    // MARK: - Test Helpers

    private func makeDate(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
    }

    private func makeSummary(daysAgo: Int, vitaminCAmount: Double) -> DailyIntakeSummary {
        let date = makeDate(daysAgo: daysAgo)
        let record = IntakeRecord(
            supplementName: "Test",
            date: date,
            timeOfDay: .morning,
            servingsTaken: 1,
            nutrients: [Nutrient(type: .vitaminC, amount: vitaminCAmount)]
        )
        return DailyIntakeSummary(date: date, records: [record])
    }

    // MARK: - Trend Enum Tests

    @Suite("Trend Enum Tests")
    struct TrendEnumTests {

        @Test("Trend has three cases")
        func testTrendCases() {
            #expect(Trend.allCases.count == 3)
            #expect(Trend.allCases.contains(.increasing))
            #expect(Trend.allCases.contains(.decreasing))
            #expect(Trend.allCases.contains(.stable))
        }

        @Test("Trend has correct display names")
        func testTrendDisplayNames() {
            #expect(Trend.increasing.displayName == "上升")
            #expect(Trend.decreasing.displayName == "下降")
            #expect(Trend.stable.displayName == "稳定")
        }
    }

    // MARK: - DataPoint Tests

    @Suite("DataPoint Tests")
    struct DataPointTests {

        @Test("DataPoint initializes correctly")
        func testDataPointInit() {
            let date = Date()
            let dataPoint = DataPoint(date: date, value: 100)

            #expect(dataPoint.date == date)
            #expect(dataPoint.value == 100)
        }
    }

    // MARK: - Initialization Tests

    @Suite("Initialization Tests")
    struct InitializationTests {

        @Test("WeeklyTrend initializes with dates and summaries")
        func testInitialization() {
            let startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
            let endDate = Date()
            let summaries: [DailyIntakeSummary] = []

            let trend = WeeklyTrend(startDate: startDate, endDate: endDate, dailySummaries: summaries)

            #expect(trend.startDate == startDate)
            #expect(trend.endDate == endDate)
            #expect(trend.dailySummaries.isEmpty)
        }

        @Test("WeeklyTrend stores summaries correctly")
        func testStoresSummaries() {
            let startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
            let endDate = Date()
            let summary1 = DailyIntakeSummary(date: startDate, records: [])
            let summary2 = DailyIntakeSummary(date: endDate, records: [])

            let trend = WeeklyTrend(startDate: startDate, endDate: endDate, dailySummaries: [summary1, summary2])

            #expect(trend.dailySummaries.count == 2)
        }
    }

    // MARK: - Average Intake Tests

    @Suite("Average Intake Tests")
    struct AverageIntakeTests {

        @Test("averageIntake returns 0 for empty summaries")
        func testEmptyAverage() {
            let trend = WeeklyTrend(
                startDate: Date(),
                endDate: Date(),
                dailySummaries: []
            )

            #expect(trend.averageIntake(for: .vitaminC) == 0)
        }

        @Test("averageIntake calculates correct average")
        func testAverageCalculation() {
            let record1 = IntakeRecord(
                supplementName: "A",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let record2 = IntakeRecord(
                supplementName: "B",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 200)]
            )
            let record3 = IntakeRecord(
                supplementName: "C",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 300)]
            )

            let summary1 = DailyIntakeSummary(date: Date(), records: [record1])
            let summary2 = DailyIntakeSummary(date: Date(), records: [record2])
            let summary3 = DailyIntakeSummary(date: Date(), records: [record3])

            let trend = WeeklyTrend(
                startDate: Date(),
                endDate: Date(),
                dailySummaries: [summary1, summary2, summary3]
            )

            // Average = (100 + 200 + 300) / 3 = 200
            #expect(trend.averageIntake(for: .vitaminC) == 200)
        }

        @Test("averageIntake handles nutrient not present in all days")
        func testAverageWithMissingDays() {
            let record1 = IntakeRecord(
                supplementName: "A",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let record2 = IntakeRecord(
                supplementName: "B",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [] // No vitamin C
            )

            let summary1 = DailyIntakeSummary(date: Date(), records: [record1])
            let summary2 = DailyIntakeSummary(date: Date(), records: [record2])

            let trend = WeeklyTrend(
                startDate: Date(),
                endDate: Date(),
                dailySummaries: [summary1, summary2]
            )

            // Average = (100 + 0) / 2 = 50
            #expect(trend.averageIntake(for: .vitaminC) == 50)
        }
    }

    // MARK: - Trend Calculation Tests

    @Suite("Trend Calculation Tests")
    struct TrendCalculationTests {

        @Test("trend returns stable for empty summaries")
        func testEmptyTrend() {
            let trend = WeeklyTrend(
                startDate: Date(),
                endDate: Date(),
                dailySummaries: []
            )

            #expect(trend.trend(for: .vitaminC) == .stable)
        }

        @Test("trend returns stable for single day")
        func testSingleDayTrend() {
            let record = IntakeRecord(
                supplementName: "A",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let summary = DailyIntakeSummary(date: Date(), records: [record])

            let trend = WeeklyTrend(
                startDate: Date(),
                endDate: Date(),
                dailySummaries: [summary]
            )

            #expect(trend.trend(for: .vitaminC) == .stable)
        }

        @Test("trend returns increasing when values go up")
        func testIncreasingTrend() {
            // Create summaries with increasing vitamin C values
            let day1 = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
            let day2 = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
            let day3 = Date()

            let record1 = IntakeRecord(
                supplementName: "A",
                date: day1,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 50)]
            )
            let record2 = IntakeRecord(
                supplementName: "B",
                date: day2,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let record3 = IntakeRecord(
                supplementName: "C",
                date: day3,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 150)]
            )

            let summary1 = DailyIntakeSummary(date: day1, records: [record1])
            let summary2 = DailyIntakeSummary(date: day2, records: [record2])
            let summary3 = DailyIntakeSummary(date: day3, records: [record3])

            let trend = WeeklyTrend(
                startDate: day1,
                endDate: day3,
                dailySummaries: [summary1, summary2, summary3]
            )

            #expect(trend.trend(for: .vitaminC) == .increasing)
        }

        @Test("trend returns decreasing when values go down")
        func testDecreasingTrend() {
            let day1 = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
            let day2 = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
            let day3 = Date()

            let record1 = IntakeRecord(
                supplementName: "A",
                date: day1,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 150)]
            )
            let record2 = IntakeRecord(
                supplementName: "B",
                date: day2,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let record3 = IntakeRecord(
                supplementName: "C",
                date: day3,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 50)]
            )

            let summary1 = DailyIntakeSummary(date: day1, records: [record1])
            let summary2 = DailyIntakeSummary(date: day2, records: [record2])
            let summary3 = DailyIntakeSummary(date: day3, records: [record3])

            let trend = WeeklyTrend(
                startDate: day1,
                endDate: day3,
                dailySummaries: [summary1, summary2, summary3]
            )

            #expect(trend.trend(for: .vitaminC) == .decreasing)
        }

        @Test("trend returns stable for similar values")
        func testStableTrend() {
            let day1 = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
            let day2 = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
            let day3 = Date()

            let record1 = IntakeRecord(
                supplementName: "A",
                date: day1,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let record2 = IntakeRecord(
                supplementName: "B",
                date: day2,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 105)]
            )
            let record3 = IntakeRecord(
                supplementName: "C",
                date: day3,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )

            let summary1 = DailyIntakeSummary(date: day1, records: [record1])
            let summary2 = DailyIntakeSummary(date: day2, records: [record2])
            let summary3 = DailyIntakeSummary(date: day3, records: [record3])

            let trend = WeeklyTrend(
                startDate: day1,
                endDate: day3,
                dailySummaries: [summary1, summary2, summary3]
            )

            #expect(trend.trend(for: .vitaminC) == .stable)
        }
    }

    // MARK: - Data Points Tests

    @Suite("Data Points Tests")
    struct DataPointsTests {

        @Test("dataPoints returns empty for no summaries")
        func testEmptyDataPoints() {
            let trend = WeeklyTrend(
                startDate: Date(),
                endDate: Date(),
                dailySummaries: []
            )

            #expect(trend.dataPoints(for: .vitaminC).isEmpty)
        }

        @Test("dataPoints returns correct values")
        func testDataPointsValues() {
            let day1 = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
            let day2 = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let day3 = Date()

            let record1 = IntakeRecord(
                supplementName: "A",
                date: day1,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let record2 = IntakeRecord(
                supplementName: "B",
                date: day2,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 200)]
            )
            let record3 = IntakeRecord(
                supplementName: "C",
                date: day3,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 300)]
            )

            let summary1 = DailyIntakeSummary(date: day1, records: [record1])
            let summary2 = DailyIntakeSummary(date: day2, records: [record2])
            let summary3 = DailyIntakeSummary(date: day3, records: [record3])

            let trend = WeeklyTrend(
                startDate: day1,
                endDate: day3,
                dailySummaries: [summary1, summary2, summary3]
            )

            let points = trend.dataPoints(for: .vitaminC)

            #expect(points.count == 3)
            #expect(points[0].value == 100)
            #expect(points[1].value == 200)
            #expect(points[2].value == 300)
        }

        @Test("dataPoints are sorted by date")
        func testDataPointsSorted() {
            let day1 = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
            let day2 = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let day3 = Date()

            let record1 = IntakeRecord(
                supplementName: "A",
                date: day1,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let record2 = IntakeRecord(
                supplementName: "B",
                date: day2,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 200)]
            )
            let record3 = IntakeRecord(
                supplementName: "C",
                date: day3,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 300)]
            )

            // Add summaries in wrong order
            let summary3 = DailyIntakeSummary(date: day3, records: [record3])
            let summary1 = DailyIntakeSummary(date: day1, records: [record1])
            let summary2 = DailyIntakeSummary(date: day2, records: [record2])

            let trend = WeeklyTrend(
                startDate: day1,
                endDate: day3,
                dailySummaries: [summary3, summary1, summary2] // Wrong order
            )

            let points = trend.dataPoints(for: .vitaminC)

            // Should be sorted by date
            #expect(points.count == 3)
            for i in 0..<(points.count - 1) {
                #expect(points[i].date < points[i + 1].date)
            }
        }
    }

    // MARK: - Day Count Tests

    @Suite("Day Count Tests")
    struct DayCountTests {

        @Test("dayCount returns correct number of days")
        func testDayCount() {
            let startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
            let endDate = Date()

            let trend = WeeklyTrend(
                startDate: startDate,
                endDate: endDate,
                dailySummaries: []
            )

            #expect(trend.dayCount == 7)
        }
    }
}
