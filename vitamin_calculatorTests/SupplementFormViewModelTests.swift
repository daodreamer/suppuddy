//
//  SupplementFormViewModelTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("SupplementFormViewModel Tests")
struct SupplementFormViewModelTests {

    // MARK: - Initialization Tests

    @Suite("Initialization Tests")
    struct InitializationTests {

        @MainActor
        @Test("New supplement form initializes with empty fields")
        func testNewSupplementForm() {
            let viewModel = SupplementFormViewModel()

            #expect(viewModel.name == "")
            #expect(viewModel.brand == "")
            #expect(viewModel.servingSize == "")
            #expect(viewModel.servingsPerDay == 1)
            #expect(viewModel.notes == "")
            #expect(viewModel.nutrients.isEmpty)
            #expect(viewModel.isActive == true)
            #expect(viewModel.isEditing == false)
        }

        @MainActor
        @Test("Edit supplement form initializes with supplement data")
        func testEditSupplementForm() {
            let supplement = Supplement(
                name: "Vitamin C",
                brand: "HealthPlus",
                servingSize: "1 tablet",
                servingsPerDay: 2,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)],
                notes: "Take with food",
                isActive: false
            )

            let viewModel = SupplementFormViewModel(supplement: supplement)

            #expect(viewModel.name == "Vitamin C")
            #expect(viewModel.brand == "HealthPlus")
            #expect(viewModel.servingSize == "1 tablet")
            #expect(viewModel.servingsPerDay == 2)
            #expect(viewModel.notes == "Take with food")
            #expect(viewModel.nutrients.count == 1)
            #expect(viewModel.isActive == false)
            #expect(viewModel.isEditing == true)
        }
    }

    // MARK: - Validation Tests

    @Suite("Validation Tests")
    struct ValidationTests {

        @MainActor
        @Test("Valid form passes validation")
        func testValidForm() {
            let viewModel = SupplementFormViewModel()
            viewModel.name = "Vitamin C"
            viewModel.servingSize = "1 tablet"
            viewModel.servingsPerDay = 1

            let isValid = viewModel.validate()

            #expect(isValid == true)
            #expect(viewModel.validationErrors.isEmpty)
        }

        @MainActor
        @Test("Empty name fails validation")
        func testEmptyNameFails() {
            let viewModel = SupplementFormViewModel()
            viewModel.name = ""
            viewModel.servingSize = "1 tablet"

            let isValid = viewModel.validate()

            #expect(isValid == false)
            #expect(viewModel.validationErrors.contains(.emptyName))
        }

        @MainActor
        @Test("Empty serving size fails validation")
        func testEmptyServingSizeFails() {
            let viewModel = SupplementFormViewModel()
            viewModel.name = "Test"
            viewModel.servingSize = ""

            let isValid = viewModel.validate()

            #expect(isValid == false)
            #expect(viewModel.validationErrors.contains(.emptyServingSize))
        }

        @MainActor
        @Test("Zero servings per day fails validation")
        func testZeroServingsPerDayFails() {
            let viewModel = SupplementFormViewModel()
            viewModel.name = "Test"
            viewModel.servingSize = "1 tablet"
            viewModel.servingsPerDay = 0

            let isValid = viewModel.validate()

            #expect(isValid == false)
            #expect(viewModel.validationErrors.contains(.invalidServingsPerDay))
        }
    }

    // MARK: - Nutrient Management Tests

    @Suite("Nutrient Management Tests")
    struct NutrientManagementTests {

        @MainActor
        @Test("Add nutrient to form")
        func testAddNutrient() {
            let viewModel = SupplementFormViewModel()

            viewModel.addNutrient(type: .vitaminC, amount: 100)

            #expect(viewModel.nutrients.count == 1)
            #expect(viewModel.nutrients.first?.type == .vitaminC)
            #expect(viewModel.nutrients.first?.amount == 100)
        }

        @MainActor
        @Test("Remove nutrient from form")
        func testRemoveNutrient() {
            let viewModel = SupplementFormViewModel()
            viewModel.addNutrient(type: .vitaminC, amount: 100)
            viewModel.addNutrient(type: .vitaminD, amount: 20)

            viewModel.removeNutrient(at: 0)

            #expect(viewModel.nutrients.count == 1)
            #expect(viewModel.nutrients.first?.type == .vitaminD)
        }

        @MainActor
        @Test("Update nutrient amount")
        func testUpdateNutrientAmount() {
            let viewModel = SupplementFormViewModel()
            viewModel.addNutrient(type: .vitaminC, amount: 100)

            viewModel.updateNutrientAmount(at: 0, amount: 200)

            #expect(viewModel.nutrients.first?.amount == 200)
        }
    }

    // MARK: - Save Tests

    @Suite("Save Tests")
    struct SaveTests {

        @MainActor
        @Test("Create new supplement from form")
        func testCreateSupplement() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let viewModel = SupplementFormViewModel()
            viewModel.name = "New Supplement"
            viewModel.servingSize = "1 tablet"
            viewModel.servingsPerDay = 1
            viewModel.addNutrient(type: .vitaminC, amount: 100)

            let success = await viewModel.save(using: repository)

            #expect(success == true)

            let supplements = try await repository.getAll()
            #expect(supplements.count == 1)
            #expect(supplements.first?.name == "New Supplement")
        }

        @MainActor
        @Test("Update existing supplement from form")
        func testUpdateSupplement() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement = Supplement(name: "Original", servingSize: "1 tablet")
            try await repository.save(supplement)

            let viewModel = SupplementFormViewModel(supplement: supplement)
            viewModel.name = "Updated"
            viewModel.servingSize = "2 tablets"

            let success = await viewModel.save(using: repository)

            #expect(success == true)
            #expect(supplement.name == "Updated")
            #expect(supplement.servingSize == "2 tablets")
        }

        @MainActor
        @Test("Save fails when validation fails")
        func testSaveFailsOnInvalidForm() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let viewModel = SupplementFormViewModel()
            viewModel.name = ""
            viewModel.servingSize = ""

            let success = await viewModel.save(using: repository)

            #expect(success == false)

            let supplements = try await repository.getAll()
            #expect(supplements.isEmpty)
        }
    }
}
