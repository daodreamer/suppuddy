//
//  SupplementDetailViewModelTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("SupplementDetailViewModel Tests")
struct SupplementDetailViewModelTests {

    // MARK: - Initialization Tests

    @Suite("Initialization Tests")
    struct InitializationTests {

        @MainActor
        @Test("ViewModel initializes with supplement data")
        func testInitialization() {
            let supplement = Supplement(
                name: "Vitamin C",
                brand: "HealthPlus",
                servingSize: "1 tablet",
                servingsPerDay: 2,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)],
                notes: "Take with food"
            )

            let viewModel = SupplementDetailViewModel(supplement: supplement)

            #expect(viewModel.supplement.name == "Vitamin C")
            #expect(viewModel.supplement.brand == "HealthPlus")
        }
    }

    // MARK: - Nutrient Info Tests

    @Suite("Nutrient Info Tests")
    struct NutrientInfoTests {

        @MainActor
        @Test("Get daily amounts for all nutrients")
        func testDailyAmounts() {
            let supplement = Supplement(
                name: "Multi",
                servingSize: "1 tablet",
                servingsPerDay: 2,
                nutrients: [
                    Nutrient(type: .vitaminC, amount: 50),
                    Nutrient(type: .vitaminD, amount: 10)
                ]
            )

            let viewModel = SupplementDetailViewModel(supplement: supplement)
            let dailyAmounts = viewModel.dailyNutrientAmounts

            #expect(dailyAmounts[.vitaminC] == 100)
            #expect(dailyAmounts[.vitaminD] == 20)
        }
    }

    // MARK: - Percentage Calculation Tests

    @Suite("Percentage Calculation Tests")
    struct PercentageTests {

        @MainActor
        @Test("Calculate percentage of recommendation for male user")
        func testPercentageForMale() {
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 55)]
            )

            let viewModel = SupplementDetailViewModel(supplement: supplement)
            let percentage = viewModel.percentageOfRecommendation(for: .vitaminC, userType: .male)

            #expect(percentage == 50.0)
        }

        @MainActor
        @Test("Calculate percentage of recommendation for female user")
        func testPercentageForFemale() {
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 95)]
            )

            let viewModel = SupplementDetailViewModel(supplement: supplement)
            let percentage = viewModel.percentageOfRecommendation(for: .vitaminC, userType: .female)

            #expect(percentage == 100.0)
        }
    }

    // MARK: - Status Calculation Tests

    @Suite("Status Calculation Tests")
    struct StatusTests {

        @MainActor
        @Test("Status is insufficient when below 80%")
        func testInsufficientStatus() {
            let supplement = Supplement(
                name: "Low Vitamin C",
                servingSize: "1 tablet",
                nutrients: [Nutrient(type: .vitaminC, amount: 50)]
            )

            let viewModel = SupplementDetailViewModel(supplement: supplement)
            let status = viewModel.nutrientStatus(for: .vitaminC, userType: .male)

            #expect(status == .insufficient)
        }

        @MainActor
        @Test("Status is normal when adequate")
        func testNormalStatus() {
            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )

            let viewModel = SupplementDetailViewModel(supplement: supplement)
            let status = viewModel.nutrientStatus(for: .vitaminC, userType: .male)

            #expect(status == .normal)
        }

        @MainActor
        @Test("Status is excessive when above upper limit")
        func testExcessiveStatus() {
            let supplement = Supplement(
                name: "Mega Vitamin C",
                servingSize: "1 tablet",
                nutrients: [Nutrient(type: .vitaminC, amount: 2500)]
            )

            let viewModel = SupplementDetailViewModel(supplement: supplement)
            let status = viewModel.nutrientStatus(for: .vitaminC, userType: .male)

            #expect(status == .excessive)
        }
    }

    // MARK: - Toggle Active Tests

    @Suite("Toggle Active Tests")
    struct ToggleActiveTests {

        @MainActor
        @Test("Toggle active state")
        func testToggleActive() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement = Supplement(name: "Test", servingSize: "1 tablet", isActive: true)
            try await repository.save(supplement)

            let viewModel = SupplementDetailViewModel(supplement: supplement)
            await viewModel.toggleActive(using: repository)

            #expect(viewModel.supplement.isActive == false)
        }
    }
}
