//
//  DailyIntakeSummaryTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("DailyIntakeSummary Tests")
struct DailyIntakeSummaryTests {

    // MARK: - Test Helpers

    private func makeRecord(
        supplementName: String,
        nutrients: [Nutrient],
        servingsTaken: Int = 1,
        timeOfDay: TimeOfDay = .morning
    ) -> IntakeRecord {
        IntakeRecord(
            supplementName: supplementName,
            date: Date(),
            timeOfDay: timeOfDay,
            servingsTaken: servingsTaken,
            nutrients: nutrients
        )
    }

    // MARK: - Initialization Tests

    @Suite("Initialization Tests")
    struct InitializationTests {

        @Test("DailyIntakeSummary initializes with date and records")
        func testInitialization() {
            let date = Date()
            let records: [IntakeRecord] = []

            let summary = DailyIntakeSummary(date: date, records: records)

            #expect(summary.date == date)
            #expect(summary.records.isEmpty)
        }

        @Test("DailyIntakeSummary stores records correctly")
        func testStoresRecords() {
            let record1 = IntakeRecord(
                supplementName: "Vitamin C",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let record2 = IntakeRecord(
                supplementName: "Vitamin D",
                date: Date(),
                timeOfDay: .evening,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminD, amount: 20)]
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record1, record2])

            #expect(summary.records.count == 2)
        }
    }

    // MARK: - Total Nutrients Calculation Tests

    @Suite("Total Nutrients Tests")
    struct TotalNutrientsTests {

        @Test("totalNutrients aggregates from single record")
        func testTotalNutrientsSingleRecord() {
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 2,
                nutrients: [
                    Nutrient(type: .vitaminC, amount: 100),
                    Nutrient(type: .vitaminD, amount: 20)
                ]
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record])
            let totals = summary.totalNutrients

            #expect(totals[.vitaminC] == 200) // 100 * 2 servings
            #expect(totals[.vitaminD] == 40)  // 20 * 2 servings
        }

        @Test("totalNutrients aggregates from multiple records")
        func testTotalNutrientsMultipleRecords() {
            let record1 = IntakeRecord(
                supplementName: "Vitamin C",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let record2 = IntakeRecord(
                supplementName: "Multi",
                date: Date(),
                timeOfDay: .evening,
                servingsTaken: 1,
                nutrients: [
                    Nutrient(type: .vitaminC, amount: 50),
                    Nutrient(type: .vitaminD, amount: 20)
                ]
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record1, record2])
            let totals = summary.totalNutrients

            #expect(totals[.vitaminC] == 150) // 100 + 50
            #expect(totals[.vitaminD] == 20)
        }

        @Test("totalNutrients returns empty for no records")
        func testTotalNutrientsEmptyRecords() {
            let summary = DailyIntakeSummary(date: Date(), records: [])
            #expect(summary.totalNutrients.isEmpty)
        }

        @Test("totalAmount returns correct amount for nutrient")
        func testTotalAmountForNutrient() {
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 2,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record])

            #expect(summary.totalAmount(for: .vitaminC) == 200)
            #expect(summary.totalAmount(for: .vitaminD) == 0)
        }
    }

    // MARK: - Completion Percentage Tests

    @Suite("Completion Percentage Tests")
    struct CompletionPercentageTests {

        @Test("completionPercentage returns 0 for no intake")
        func testZeroIntake() {
            let summary = DailyIntakeSummary(date: Date(), records: [])

            let percentage = summary.completionPercentage(for: .vitaminC, userType: .male)

            #expect(percentage == 0)
        }

        @Test("completionPercentage returns correct percentage for male")
        func testPercentageForMale() {
            // DGE Vitamin C recommendation for male is 110mg
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 55)] // 50% of 110
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record])
            let percentage = summary.completionPercentage(for: .vitaminC, userType: .male)

            #expect(percentage == 50)
        }

        @Test("completionPercentage returns correct percentage for female")
        func testPercentageForFemale() {
            // DGE Vitamin C recommendation for female is 95mg
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 95)] // 100% of 95
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record])
            let percentage = summary.completionPercentage(for: .vitaminC, userType: .female)

            #expect(percentage == 100)
        }

        @Test("completionPercentage can exceed 100")
        func testExceeds100() {
            // DGE Vitamin C recommendation for male is 110mg
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 220)] // 200% of 110
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record])
            let percentage = summary.completionPercentage(for: .vitaminC, userType: .male)

            #expect(percentage == 200)
        }
    }

    // MARK: - Nutrient Status Tests

    @Suite("Nutrient Status Tests")
    struct NutrientStatusTests {

        @Test("status returns none for no intake")
        func testNoIntake() {
            let summary = DailyIntakeSummary(date: Date(), records: [])
            let status = summary.status(for: .vitaminC, userType: .male)
            #expect(status == .none)
        }

        @Test("status returns insufficient for less than 80%")
        func testInsufficient() {
            // DGE Vitamin C for male is 110mg. 80% = 88mg
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 50)] // ~45% - insufficient
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record])
            let status = summary.status(for: .vitaminC, userType: .male)

            #expect(status == .insufficient)
        }

        @Test("status returns normal for 80-100%")
        func testNormal() {
            // DGE Vitamin C for male is 110mg
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)] // ~91%
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record])
            let status = summary.status(for: .vitaminC, userType: .male)

            #expect(status == .normal)
        }

        @Test("status returns excessive when exceeding upper limit")
        func testExcessive() {
            // DGE Vitamin A for male: recommended 850μg, upper limit 3000μg
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminA, amount: 3500)] // Above upper limit
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record])
            let status = summary.status(for: .vitaminA, userType: .male)

            #expect(status == .excessive)
        }
    }

    // MARK: - Nutrient Sources Tests

    @Suite("Nutrient Sources Tests")
    struct NutrientSourcesTests {

        @Test("nutrientSources returns empty for nutrient not in records")
        func testNoSources() {
            let record = IntakeRecord(
                supplementName: "Vitamin C",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record])
            let sources = summary.nutrientSources(for: .vitaminD)

            #expect(sources.isEmpty)
        }

        @Test("nutrientSources returns all contributing supplements")
        func testMultipleSources() {
            let record1 = IntakeRecord(
                supplementName: "Vitamin C Pure",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let record2 = IntakeRecord(
                supplementName: "Multi-Vitamin",
                date: Date(),
                timeOfDay: .evening,
                servingsTaken: 2,
                nutrients: [Nutrient(type: .vitaminC, amount: 50)]
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record1, record2])
            let sources = summary.nutrientSources(for: .vitaminC)

            #expect(sources.count == 2)
            #expect(sources.contains(where: { $0.supplementName == "Vitamin C Pure" && $0.amount == 100 }))
            #expect(sources.contains(where: { $0.supplementName == "Multi-Vitamin" && $0.amount == 100 })) // 50 * 2 servings
        }

        @Test("nutrientSources calculates total amount per supplement")
        func testTotalAmountPerSupplement() {
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 3,
                nutrients: [Nutrient(type: .vitaminC, amount: 50)]
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record])
            let sources = summary.nutrientSources(for: .vitaminC)

            #expect(sources.count == 1)
            #expect(sources.first?.amount == 150) // 50 * 3 servings
        }
    }

    // MARK: - Record Count Tests

    @Suite("Record Count Tests")
    struct RecordCountTests {

        @Test("recordCount returns 0 for empty records")
        func testEmptyRecordCount() {
            let summary = DailyIntakeSummary(date: Date(), records: [])
            #expect(summary.recordCount == 0)
        }

        @Test("recordCount returns correct count")
        func testRecordCount() {
            let record1 = IntakeRecord(
                supplementName: "A",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            let record2 = IntakeRecord(
                supplementName: "B",
                date: Date(),
                timeOfDay: .noon,
                servingsTaken: 1,
                nutrients: []
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record1, record2])
            #expect(summary.recordCount == 2)
        }
    }

    // MARK: - Covered Nutrients Tests

    @Suite("Covered Nutrients Tests")
    struct CoveredNutrientsTests {

        @Test("coveredNutrients returns all unique nutrient types")
        func testCoveredNutrients() {
            let record1 = IntakeRecord(
                supplementName: "A",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [
                    Nutrient(type: .vitaminC, amount: 100),
                    Nutrient(type: .vitaminD, amount: 20)
                ]
            )
            let record2 = IntakeRecord(
                supplementName: "B",
                date: Date(),
                timeOfDay: .evening,
                servingsTaken: 1,
                nutrients: [
                    Nutrient(type: .vitaminC, amount: 50), // duplicate
                    Nutrient(type: .calcium, amount: 500)
                ]
            )

            let summary = DailyIntakeSummary(date: Date(), records: [record1, record2])
            let covered = summary.coveredNutrients

            #expect(covered.count == 3)
            #expect(covered.contains(.vitaminC))
            #expect(covered.contains(.vitaminD))
            #expect(covered.contains(.calcium))
        }

        @Test("coveredNutrients returns empty for no records")
        func testEmptyCoveredNutrients() {
            let summary = DailyIntakeSummary(date: Date(), records: [])
            #expect(summary.coveredNutrients.isEmpty)
        }
    }
}
