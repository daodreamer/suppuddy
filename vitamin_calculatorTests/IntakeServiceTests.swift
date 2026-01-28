//
//  IntakeServiceTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("IntakeService Tests")
struct IntakeServiceTests {

    // MARK: - TipType Tests

    @Suite("TipType Tests")
    struct TipTypeTests {

        @Test("TipType has three cases")
        func testTipTypeCases() {
            #expect(TipType.allCases.count == 3)
            #expect(TipType.allCases.contains(.warning))
            #expect(TipType.allCases.contains(.suggestion))
            #expect(TipType.allCases.contains(.info))
        }
    }

    // MARK: - HealthTip Tests

    @Suite("HealthTip Tests")
    struct HealthTipTests {

        @Test("HealthTip initializes correctly")
        func testHealthTipInit() {
            let tip = HealthTip(
                type: .warning,
                nutrient: .vitaminA,
                message: "Vitamin A intake exceeds safe limit"
            )

            #expect(tip.type == .warning)
            #expect(tip.nutrient == .vitaminA)
            #expect(tip.message == "Vitamin A intake exceeds safe limit")
        }

        @Test("HealthTip can have nil nutrient")
        func testHealthTipNilNutrient() {
            let tip = HealthTip(
                type: .info,
                nutrient: nil,
                message: "General health tip"
            )

            #expect(tip.nutrient == nil)
        }
    }

    // MARK: - Record Intake Tests

    @Suite("Record Intake Tests")
    struct RecordIntakeTests {

        @Test("recordIntake creates IntakeRecord with correct data")
        func testRecordIntake() {
            let service = IntakeService()
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let date = Date()

            let record = service.recordIntake(
                supplement: supplement,
                servings: 2,
                timeOfDay: .morning,
                date: date
            )

            #expect(record.supplementName == "Vitamin C")
            #expect(record.servingsTaken == 2)
            #expect(record.timeOfDay == .morning)
            #expect(record.nutrients.count == 1)
            #expect(record.nutrients.first?.type == .vitaminC)
            #expect(record.nutrients.first?.amount == 100)
        }

        @Test("recordIntake associates supplement reference")
        func testRecordIntakeAssociatesSupplement() {
            let service = IntakeService()
            let supplement = Supplement(
                name: "Multi",
                servingSize: "1 capsule",
                nutrients: []
            )

            let record = service.recordIntake(
                supplement: supplement,
                servings: 1,
                timeOfDay: .evening,
                date: Date()
            )

            #expect(record.supplement === supplement)
        }
    }

    // MARK: - Daily Summary Tests

    @Suite("Daily Summary Tests")
    struct DailySummaryTests {

        @Test("getDailySummary creates summary from records")
        func testGetDailySummary() {
            let service = IntakeService()
            let date = Date()
            let user = UserProfile(name: "Test", userType: .male)
            let record = IntakeRecord(
                supplementName: "Test",
                date: date,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )

            let summary = service.getDailySummary(for: date, records: [record], user: user)

            #expect(summary.date == date)
            #expect(summary.recordCount == 1)
        }

        @Test("getDailySummary filters records by date")
        func testGetDailySummaryFiltersByDate() {
            let service = IntakeService()
            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            let user = UserProfile(name: "Test", userType: .male)

            let todayRecord = IntakeRecord(
                supplementName: "Today",
                date: today,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            let yesterdayRecord = IntakeRecord(
                supplementName: "Yesterday",
                date: yesterday,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )

            let summary = service.getDailySummary(
                for: today,
                records: [todayRecord, yesterdayRecord],
                user: user
            )

            #expect(summary.recordCount == 1)
        }
    }

    // MARK: - Weekly Trend Tests

    @Suite("Weekly Trend Tests")
    struct WeeklyTrendTests {

        @Test("getWeeklyTrend creates trend from records")
        func testGetWeeklyTrend() {
            let service = IntakeService()
            let today = Date()
            var records: [IntakeRecord] = []

            // Create records for 7 days
            for i in 0..<7 {
                let date = Calendar.current.date(byAdding: .day, value: -i, to: today)!
                let record = IntakeRecord(
                    supplementName: "Test \(i)",
                    date: date,
                    timeOfDay: .morning,
                    servingsTaken: 1,
                    nutrients: [Nutrient(type: .vitaminC, amount: Double(100 + i * 10))]
                )
                records.append(record)
            }

            let trend = service.getWeeklyTrend(endingOn: today, records: records)

            #expect(trend.dayCount == 7)
            #expect(trend.dailySummaries.count == 7)
        }

        @Test("getWeeklyTrend only includes last 7 days")
        func testGetWeeklyTrendOnly7Days() {
            let service = IntakeService()
            let today = Date()
            var records: [IntakeRecord] = []

            // Create records for 10 days
            for i in 0..<10 {
                let date = Calendar.current.date(byAdding: .day, value: -i, to: today)!
                let record = IntakeRecord(
                    supplementName: "Test \(i)",
                    date: date,
                    timeOfDay: .morning,
                    servingsTaken: 1,
                    nutrients: []
                )
                records.append(record)
            }

            let trend = service.getWeeklyTrend(endingOn: today, records: records)

            // Should only include last 7 days of data
            #expect(trend.dayCount == 7)
        }
    }

    // MARK: - Missing Nutrients Tests

    @Suite("Missing Nutrients Tests")
    struct MissingNutrientsTests {

        @Test("getMissingNutrients returns nutrients below 80%")
        func testGetMissingNutrients() {
            let service = IntakeService()
            let user = UserProfile(name: "Test", userType: .male)

            // DGE Vitamin C for male is 110mg, 80% = 88mg
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 50)] // Below 80%
            )
            let summary = DailyIntakeSummary(date: Date(), records: [record])

            let missing = service.getMissingNutrients(summary: summary, user: user)

            #expect(missing.contains(.vitaminC))
        }

        @Test("getMissingNutrients excludes nutrients at or above 80%")
        func testExcludesAdequateNutrients() {
            let service = IntakeService()
            let user = UserProfile(name: "Test", userType: .male)

            // DGE Vitamin C for male is 110mg
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 110)] // 100%
            )
            let summary = DailyIntakeSummary(date: Date(), records: [record])

            let missing = service.getMissingNutrients(summary: summary, user: user)

            #expect(!missing.contains(.vitaminC))
        }
    }

    // MARK: - Excessive Nutrients Tests

    @Suite("Excessive Nutrients Tests")
    struct ExcessiveNutrientsTests {

        @Test("getExcessiveNutrients returns nutrients above upper limit")
        func testGetExcessiveNutrients() {
            let service = IntakeService()
            let user = UserProfile(name: "Test", userType: .male)

            // DGE Vitamin A upper limit is 3000μg
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminA, amount: 3500)] // Above upper limit
            )
            let summary = DailyIntakeSummary(date: Date(), records: [record])

            let excessive = service.getExcessiveNutrients(summary: summary, user: user)

            #expect(excessive.contains(.vitaminA))
        }

        @Test("getExcessiveNutrients excludes nutrients within limit")
        func testExcludesNormalNutrients() {
            let service = IntakeService()
            let user = UserProfile(name: "Test", userType: .male)

            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminA, amount: 1000)] // Within limit
            )
            let summary = DailyIntakeSummary(date: Date(), records: [record])

            let excessive = service.getExcessiveNutrients(summary: summary, user: user)

            #expect(!excessive.contains(.vitaminA))
        }
    }

    // MARK: - Health Tips Tests

    @Suite("Health Tips Tests")
    struct HealthTipsTests {

        @Test("generateHealthTips creates warning for excessive intake")
        func testWarningForExcessive() {
            let service = IntakeService()
            let user = UserProfile(name: "Test", userType: .male)

            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminA, amount: 3500)] // Excessive
            )
            let summary = DailyIntakeSummary(date: Date(), records: [record])

            let tips = service.generateHealthTips(summary: summary, user: user)

            let hasWarning = tips.contains { $0.type == .warning && $0.nutrient == .vitaminA }
            #expect(hasWarning)
        }

        @Test("generateHealthTips creates suggestion for insufficient intake")
        func testSuggestionForInsufficient() {
            let service = IntakeService()
            let user = UserProfile(name: "Test", userType: .male)

            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 30)] // Insufficient
            )
            let summary = DailyIntakeSummary(date: Date(), records: [record])

            let tips = service.generateHealthTips(summary: summary, user: user)

            let hasSuggestion = tips.contains { $0.type == .suggestion && $0.nutrient == .vitaminC }
            #expect(hasSuggestion)
        }

        @Test("generateHealthTips returns empty for balanced intake")
        func testNoTipsForBalanced() {
            let service = IntakeService()
            let user = UserProfile(name: "Test", userType: .male)

            // Create a record with balanced vitamin C intake
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 110)] // Exactly at recommended
            )
            let summary = DailyIntakeSummary(date: Date(), records: [record])

            let tips = service.generateHealthTips(summary: summary, user: user)

            // Should have no warnings or suggestions for vitamin C
            let vitaminCTips = tips.filter { $0.nutrient == .vitaminC }
            #expect(vitaminCTips.isEmpty)
        }
    }
}
