//
//  SupplementServiceTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("SupplementService Tests")
struct SupplementServiceTests {

    // MARK: - Total Nutrients Calculation Tests

    @Suite("Total Nutrients Calculation Tests")
    struct TotalNutrientsTests {

        @Test("Calculate total nutrients from single supplement")
        func testSingleSupplementTotal() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )

            let totals = service.calculateTotalNutrients(from: [supplement])

            #expect(totals[.vitaminC] == 100)
        }

        @Test("Calculate total nutrients from multiple supplements")
        func testMultipleSupplementsTotal() {
            let service = SupplementService()
            let supplement1 = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let supplement2 = Supplement(
                name: "Multi-Vitamin",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [
                    Nutrient(type: .vitaminC, amount: 50),
                    Nutrient(type: .vitaminD, amount: 20)
                ]
            )

            let totals = service.calculateTotalNutrients(from: [supplement1, supplement2])

            #expect(totals[.vitaminC] == 150)
            #expect(totals[.vitaminD] == 20)
        }

        @Test("Calculate total nutrients with multiple servings per day")
        func testMultipleServingsTotal() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                servingsPerDay: 3,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )

            let totals = service.calculateTotalNutrients(from: [supplement])

            #expect(totals[.vitaminC] == 300)
        }

        @Test("Calculate total nutrients returns empty for empty list")
        func testEmptyListTotal() {
            let service = SupplementService()

            let totals = service.calculateTotalNutrients(from: [])

            #expect(totals.isEmpty)
        }

        @Test("Calculate total nutrients only includes active supplements")
        func testOnlyActiveSupplements() {
            let service = SupplementService()
            let activeSupp = Supplement(
                name: "Active",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)],
                isActive: true
            )
            let inactiveSupp = Supplement(
                name: "Inactive",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 50)],
                isActive: false
            )

            let totals = service.calculateTotalNutrients(from: [activeSupp, inactiveSupp])

            #expect(totals[.vitaminC] == 100)
        }
    }

    // MARK: - Comparison with Recommendations Tests

    @Suite("Comparison with Recommendations Tests")
    struct ComparisonTests {

        @Test("Compare nutrients with recommendations for male user")
        func testComparisonForMale() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 110)]
            )
            let user = UserProfile(name: "Test", userType: .male)

            let comparisons = service.compareWithRecommendations(
                supplements: [supplement],
                user: user
            )

            let vitaminCComparison = comparisons.first { $0.nutrientType == .vitaminC }
            #expect(vitaminCComparison != nil)
            #expect(vitaminCComparison?.percentage == 100)
            #expect(vitaminCComparison?.status == .normal)
        }

        @Test("Compare nutrients with recommendations for female user")
        func testComparisonForFemale() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 95)]
            )
            let user = UserProfile(name: "Test", userType: .female)

            let comparisons = service.compareWithRecommendations(
                supplements: [supplement],
                user: user
            )

            let vitaminCComparison = comparisons.first { $0.nutrientType == .vitaminC }
            #expect(vitaminCComparison != nil)
            #expect(vitaminCComparison?.percentage == 100)
            #expect(vitaminCComparison?.status == .normal)
        }

        @Test("Comparison shows insufficient status when below 80%")
        func testInsufficientComparison() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "Low Vitamin C",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 50)]
            )
            let user = UserProfile(name: "Test", userType: .male)

            let comparisons = service.compareWithRecommendations(
                supplements: [supplement],
                user: user
            )

            let vitaminCComparison = comparisons.first { $0.nutrientType == .vitaminC }
            #expect(vitaminCComparison?.status == .insufficient)
        }

        @Test("Comparison shows excessive status when above upper limit")
        func testExcessiveComparison() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "Mega Vitamin C",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 2500)]
            )
            let user = UserProfile(name: "Test", userType: .male)

            let comparisons = service.compareWithRecommendations(
                supplements: [supplement],
                user: user
            )

            let vitaminCComparison = comparisons.first { $0.nutrientType == .vitaminC }
            #expect(vitaminCComparison?.status == .excessive)
        }

        @Test("Comparison includes all nutrients from supplements")
        func testAllNutrientsIncluded() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "Multi",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [
                    Nutrient(type: .vitaminC, amount: 100),
                    Nutrient(type: .vitaminD, amount: 20),
                    Nutrient(type: .calcium, amount: 500)
                ]
            )
            let user = UserProfile(name: "Test", userType: .male)

            let comparisons = service.compareWithRecommendations(
                supplements: [supplement],
                user: user
            )

            #expect(comparisons.count == 3)
            #expect(comparisons.contains { $0.nutrientType == .vitaminC })
            #expect(comparisons.contains { $0.nutrientType == .vitaminD })
            #expect(comparisons.contains { $0.nutrientType == .calcium })
        }
    }

    // MARK: - Validation Tests

    @Suite("Validation Tests")
    struct ValidationTests {

        @Test("Valid supplement passes validation")
        func testValidSupplement() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "Valid Supplement",
                servingSize: "1 tablet",
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )

            let errors = service.validateSupplement(supplement)

            #expect(errors.isEmpty)
        }

        @Test("Empty name fails validation")
        func testEmptyNameFails() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "",
                servingSize: "1 tablet"
            )

            let errors = service.validateSupplement(supplement)

            #expect(errors.contains(.emptyName))
        }

        @Test("Empty serving size fails validation")
        func testEmptyServingSizeFails() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "Test",
                servingSize: ""
            )

            let errors = service.validateSupplement(supplement)

            #expect(errors.contains(.emptyServingSize))
        }

        @Test("Zero servings per day fails validation")
        func testZeroServingsPerDayFails() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "Test",
                servingSize: "1 tablet",
                servingsPerDay: 0
            )

            let errors = service.validateSupplement(supplement)

            #expect(errors.contains(.invalidServingsPerDay))
        }

        @Test("Negative servings per day fails validation")
        func testNegativeServingsPerDayFails() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "Test",
                servingSize: "1 tablet",
                servingsPerDay: -1
            )

            let errors = service.validateSupplement(supplement)

            #expect(errors.contains(.invalidServingsPerDay))
        }

        @Test("Multiple validation errors can occur")
        func testMultipleErrors() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "",
                servingSize: "",
                servingsPerDay: 0
            )

            let errors = service.validateSupplement(supplement)

            #expect(errors.count == 3)
            #expect(errors.contains(.emptyName))
            #expect(errors.contains(.emptyServingSize))
            #expect(errors.contains(.invalidServingsPerDay))
        }
    }

    // MARK: - Missing Nutrients Tests

    @Suite("Missing Nutrients Tests")
    struct MissingNutrientsTests {

        @Test("Identify missing nutrients compared to all DGE nutrients")
        func testMissingNutrients() {
            let service = SupplementService()
            let supplement = Supplement(
                name: "Basic",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            let user = UserProfile(name: "Test", userType: .male)

            let missing = service.getMissingNutrients(
                supplements: [supplement],
                user: user
            )

            // Should have 22 missing (23 total - 1 present)
            #expect(missing.count == 22)
            #expect(!missing.contains(.vitaminC))
            #expect(missing.contains(.vitaminD))
        }

        @Test("No missing nutrients when all are covered")
        func testNoMissingNutrients() {
            let service = SupplementService()
            // Create supplement with all nutrients
            let nutrients = NutrientType.allCases.map { Nutrient(type: $0, amount: 100) }
            let supplement = Supplement(
                name: "Complete",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: nutrients
            )
            let user = UserProfile(name: "Test", userType: .male)

            let missing = service.getMissingNutrients(
                supplements: [supplement],
                user: user
            )

            #expect(missing.isEmpty)
        }
    }
}

// MARK: - NutrientComparison Tests

@Suite("NutrientComparison Model Tests")
struct NutrientComparisonTests {

    @Test("NutrientComparison initializes correctly")
    func testInitialization() {
        let comparison = NutrientComparison(
            nutrientType: .vitaminC,
            currentAmount: 100,
            recommendedAmount: 110,
            upperLimit: 2000,
            percentage: 90.9,
            status: .normal
        )

        #expect(comparison.nutrientType == .vitaminC)
        #expect(comparison.currentAmount == 100)
        #expect(comparison.recommendedAmount == 110)
        #expect(comparison.upperLimit == 2000)
        #expect(comparison.percentage == 90.9)
        #expect(comparison.status == .normal)
    }
}

// MARK: - SupplementValidationError Tests

@Suite("SupplementValidationError Tests")
struct SupplementValidationErrorTests {

    @Test("All validation error cases exist")
    func testAllCases() {
        let errors: [SupplementValidationError] = [
            .emptyName,
            .emptyServingSize,
            .invalidServingsPerDay
        ]
        #expect(errors.count == 3)
    }
}
