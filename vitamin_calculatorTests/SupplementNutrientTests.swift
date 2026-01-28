//
//  SupplementNutrientTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("Supplement Nutrient Relationship Tests")
struct SupplementNutrientTests {

    // MARK: - Daily Amount Calculation Tests

    @Suite("Daily Amount Calculation Tests")
    struct DailyAmountTests {

        @Test("Calculate total daily amount for single nutrient")
        func testSingleNutrientDailyAmount() {
            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                servingsPerDay: 2,
                nutrients: nutrients
            )

            let dailyAmount = supplement.totalDailyAmount(for: .vitaminC)
            #expect(dailyAmount == 200)
        }

        @Test("Calculate total daily amount for multiple nutrients")
        func testMultipleNutrientsDailyAmount() {
            let nutrients = [
                Nutrient(type: .vitaminC, amount: 100),
                Nutrient(type: .vitaminD, amount: 25),
                Nutrient(type: .calcium, amount: 500)
            ]
            let supplement = Supplement(
                name: "Multi",
                servingSize: "1 tablet",
                servingsPerDay: 2,
                nutrients: nutrients
            )

            #expect(supplement.totalDailyAmount(for: .vitaminC) == 200)
            #expect(supplement.totalDailyAmount(for: .vitaminD) == 50)
            #expect(supplement.totalDailyAmount(for: .calcium) == 1000)
        }

        @Test("Daily amount returns zero for nutrient not in supplement")
        func testMissingNutrientDailyAmount() {
            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                nutrients: nutrients
            )

            #expect(supplement.totalDailyAmount(for: .iron) == 0)
        }
    }

    // MARK: - Percentage of Recommendation Tests

    @Suite("Percentage of Recommendation Tests")
    struct PercentageTests {

        @Test("Calculate percentage of daily recommendation for male user")
        func testPercentageForMale() {
            // Vitamin C recommendation for male is 110mg
            let nutrients = [Nutrient(type: .vitaminC, amount: 55)]
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: nutrients
            )

            let percentage = supplement.percentageOfRecommendation(
                for: .vitaminC,
                userType: .male
            )

            #expect(percentage == 50.0) // 55 / 110 * 100 = 50%
        }

        @Test("Calculate percentage of daily recommendation for female user")
        func testPercentageForFemale() {
            // Vitamin C recommendation for female is 95mg
            let nutrients = [Nutrient(type: .vitaminC, amount: 95)]
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: nutrients
            )

            let percentage = supplement.percentageOfRecommendation(
                for: .vitaminC,
                userType: .female
            )

            #expect(percentage == 100.0) // 95 / 95 * 100 = 100%
        }

        @Test("Calculate percentage with multiple servings per day")
        func testPercentageWithMultipleServings() {
            // Vitamin D recommendation for male is 20μg
            let nutrients = [Nutrient(type: .vitaminD, amount: 5)]
            let supplement = Supplement(
                name: "Vitamin D",
                servingSize: "1 tablet",
                servingsPerDay: 2,
                nutrients: nutrients
            )

            let percentage = supplement.percentageOfRecommendation(
                for: .vitaminD,
                userType: .male
            )

            #expect(percentage == 50.0) // (5 * 2) / 20 * 100 = 50%
        }

        @Test("Percentage returns zero for missing nutrient")
        func testPercentageForMissingNutrient() {
            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                nutrients: nutrients
            )

            let percentage = supplement.percentageOfRecommendation(
                for: .iron,
                userType: .male
            )

            #expect(percentage == 0)
        }

        @Test("Percentage can exceed 100%")
        func testPercentageExceeds100() {
            // Vitamin C recommendation for male is 110mg
            let nutrients = [Nutrient(type: .vitaminC, amount: 220)]
            let supplement = Supplement(
                name: "High Dose Vitamin C",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: nutrients
            )

            let percentage = supplement.percentageOfRecommendation(
                for: .vitaminC,
                userType: .male
            )

            #expect(percentage == 200.0) // 220 / 110 * 100 = 200%
        }

        @Test("Calculate percentage for child user")
        func testPercentageForChild() {
            // Vitamin C recommendation for child age 7-9 is 45mg
            let nutrients = [Nutrient(type: .vitaminC, amount: 22.5)]
            let supplement = Supplement(
                name: "Kids Vitamin C",
                servingSize: "1 gummy",
                servingsPerDay: 1,
                nutrients: nutrients
            )

            let percentage = supplement.percentageOfRecommendation(
                for: .vitaminC,
                userType: .child(age: 8)
            )

            #expect(percentage == 50.0) // 22.5 / 45 * 100 = 50%
        }
    }

    // MARK: - Nutrient Status Tests

    @Suite("Nutrient Status Tests")
    struct NutrientStatusTests {

        @Test("Status is insufficient when below 80%")
        func testInsufficientStatus() {
            let nutrients = [Nutrient(type: .vitaminC, amount: 50)]
            let supplement = Supplement(
                name: "Low Vitamin C",
                servingSize: "1 tablet",
                nutrients: nutrients
            )

            let status = supplement.nutrientStatus(for: .vitaminC, userType: .male)
            #expect(status == .insufficient)
        }

        @Test("Status is normal when between 80% and upper limit")
        func testNormalStatus() {
            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                nutrients: nutrients
            )

            let status = supplement.nutrientStatus(for: .vitaminC, userType: .male)
            #expect(status == .normal)
        }

        @Test("Status is excessive when above upper limit")
        func testExcessiveStatus() {
            // Vitamin C upper limit for male is 2000mg
            let nutrients = [Nutrient(type: .vitaminC, amount: 2500)]
            let supplement = Supplement(
                name: "Mega Vitamin C",
                servingSize: "1 tablet",
                nutrients: nutrients
            )

            let status = supplement.nutrientStatus(for: .vitaminC, userType: .male)
            #expect(status == .excessive)
        }

        @Test("Status is normal when at exactly 80%")
        func testStatusAtExactly80Percent() {
            // Vitamin C recommendation for male is 110mg, 80% = 88mg
            let nutrients = [Nutrient(type: .vitaminC, amount: 88)]
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                nutrients: nutrients
            )

            let status = supplement.nutrientStatus(for: .vitaminC, userType: .male)
            #expect(status == .normal)
        }

        @Test("Status is normal when at exactly upper limit")
        func testStatusAtExactlyUpperLimit() {
            // Vitamin C upper limit is 2000mg
            let nutrients = [Nutrient(type: .vitaminC, amount: 2000)]
            let supplement = Supplement(
                name: "High Vitamin C",
                servingSize: "1 tablet",
                nutrients: nutrients
            )

            let status = supplement.nutrientStatus(for: .vitaminC, userType: .male)
            #expect(status == .normal)
        }

        @Test("Status for nutrient without upper limit")
        func testStatusWithoutUpperLimit() {
            // Vitamin K has no upper limit
            let nutrients = [Nutrient(type: .vitaminK, amount: 1000)]
            let supplement = Supplement(
                name: "Vitamin K",
                servingSize: "1 tablet",
                nutrients: nutrients
            )

            let status = supplement.nutrientStatus(for: .vitaminK, userType: .male)
            // Even with very high amount, should be normal since no upper limit
            #expect(status == .normal)
        }

        @Test("Status returns none for missing nutrient")
        func testStatusForMissingNutrient() {
            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                nutrients: nutrients
            )

            let status = supplement.nutrientStatus(for: .iron, userType: .male)
            #expect(status == .none)
        }
    }

    // MARK: - All Nutrients Info Tests

    @Suite("All Nutrients Info Tests")
    struct AllNutrientsInfoTests {

        @Test("Get all nutrients with daily amounts")
        func testAllNutrientsDailyAmounts() {
            let nutrients = [
                Nutrient(type: .vitaminC, amount: 100),
                Nutrient(type: .vitaminD, amount: 20),
                Nutrient(type: .calcium, amount: 250)
            ]
            let supplement = Supplement(
                name: "Multi",
                servingSize: "1 tablet",
                servingsPerDay: 2,
                nutrients: nutrients
            )

            let dailyAmounts = supplement.allNutrientsDailyAmounts()

            #expect(dailyAmounts.count == 3)
            #expect(dailyAmounts[.vitaminC] == 200)
            #expect(dailyAmounts[.vitaminD] == 40)
            #expect(dailyAmounts[.calcium] == 500)
        }

        @Test("Get all nutrients with empty supplement")
        func testAllNutrientsEmpty() {
            let supplement = Supplement(
                name: "Empty",
                servingSize: "1 tablet",
                nutrients: []
            )

            let dailyAmounts = supplement.allNutrientsDailyAmounts()
            #expect(dailyAmounts.isEmpty)
        }
    }
}

// MARK: - NutrientStatus Enum Tests

@Suite("NutrientStatus Enum Tests")
struct NutrientStatusEnumTests {

    @Test("NutrientStatus has all expected cases")
    func testAllCases() {
        let allCases: [NutrientStatus] = [.none, .insufficient, .normal, .excessive]
        #expect(allCases.count == 4)
    }

    @Test("NutrientStatus none case exists")
    func testNoneCase() {
        let status = NutrientStatus.none
        #expect(status == .none)
    }

    @Test("NutrientStatus insufficient case exists")
    func testInsufficientCase() {
        let status = NutrientStatus.insufficient
        #expect(status == .insufficient)
    }

    @Test("NutrientStatus normal case exists")
    func testNormalCase() {
        let status = NutrientStatus.normal
        #expect(status == .normal)
    }

    @Test("NutrientStatus excessive case exists")
    func testExcessiveCase() {
        let status = NutrientStatus.excessive
        #expect(status == .excessive)
    }
}
