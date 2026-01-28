//
//  SupplementTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("Supplement Model Tests")
struct SupplementTests {

    // MARK: - Initialization Tests

    @Suite("Initialization Tests")
    struct InitializationTests {

        @Test("Supplement initializes with required fields")
        func testBasicInitialization() {
            let supplement = Supplement(
                name: "Vitamin C Complex",
                servingSize: "1 tablet"
            )

            #expect(supplement.name == "Vitamin C Complex")
            #expect(supplement.servingSize == "1 tablet")
            #expect(supplement.brand == nil)
            #expect(supplement.notes == nil)
            #expect(supplement.imageData == nil)
            #expect(supplement.nutrients.isEmpty)
            #expect(supplement.isActive == true)
        }

        @Test("Supplement initializes with all fields")
        func testFullInitialization() {
            let nutrients = [
                Nutrient(type: .vitaminC, amount: 500),
                Nutrient(type: .vitaminD, amount: 25)
            ]
            let imageData = Data([0x00, 0x01, 0x02])

            let supplement = Supplement(
                name: "Multi-Vitamin",
                brand: "HealthPlus",
                servingSize: "2 capsules",
                servingsPerDay: 2,
                nutrients: nutrients,
                notes: "Take with food",
                imageData: imageData,
                isActive: false
            )

            #expect(supplement.name == "Multi-Vitamin")
            #expect(supplement.brand == "HealthPlus")
            #expect(supplement.servingSize == "2 capsules")
            #expect(supplement.servingsPerDay == 2)
            #expect(supplement.nutrients.count == 2)
            #expect(supplement.notes == "Take with food")
            #expect(supplement.imageData == imageData)
            #expect(supplement.isActive == false)
        }

        @Test("Supplement has timestamps on creation")
        func testTimestamps() {
            let beforeCreation = Date()
            let supplement = Supplement(name: "Test", servingSize: "1 pill")
            let afterCreation = Date()

            #expect(supplement.createdAt >= beforeCreation)
            #expect(supplement.createdAt <= afterCreation)
            #expect(supplement.updatedAt >= beforeCreation)
            #expect(supplement.updatedAt <= afterCreation)
        }

        @Test("Supplement defaults servingsPerDay to 1")
        func testDefaultServingsPerDay() {
            let supplement = Supplement(name: "Test", servingSize: "1 pill")
            #expect(supplement.servingsPerDay == 1)
        }
    }

    // MARK: - Nutrients Tests

    @Suite("Nutrients Tests")
    struct NutrientsTests {

        @Test("Can add nutrients to supplement")
        func testAddNutrients() {
            var supplement = Supplement(name: "Test", servingSize: "1 pill")
            let nutrient = Nutrient(type: .vitaminC, amount: 100)

            supplement.nutrients.append(nutrient)

            #expect(supplement.nutrients.count == 1)
            #expect(supplement.nutrients.first?.type == .vitaminC)
            #expect(supplement.nutrients.first?.amount == 100)
        }

        @Test("Can initialize with multiple nutrients")
        func testMultipleNutrients() {
            let nutrients = [
                Nutrient(type: .vitaminC, amount: 100),
                Nutrient(type: .vitaminD, amount: 20),
                Nutrient(type: .calcium, amount: 500)
            ]

            let supplement = Supplement(
                name: "Multi",
                servingSize: "1 tablet",
                nutrients: nutrients
            )

            #expect(supplement.nutrients.count == 3)
        }

        @Test("totalDailyAmount calculates correctly for single serving")
        func testTotalDailyAmountSingleServing() {
            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]
            let supplement = Supplement(
                name: "Test",
                servingSize: "1 pill",
                servingsPerDay: 1,
                nutrients: nutrients
            )

            let dailyAmount = supplement.totalDailyAmount(for: .vitaminC)
            #expect(dailyAmount == 100)
        }

        @Test("totalDailyAmount calculates correctly for multiple servings")
        func testTotalDailyAmountMultipleServings() {
            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]
            let supplement = Supplement(
                name: "Test",
                servingSize: "1 pill",
                servingsPerDay: 3,
                nutrients: nutrients
            )

            let dailyAmount = supplement.totalDailyAmount(for: .vitaminC)
            #expect(dailyAmount == 300)
        }

        @Test("totalDailyAmount returns zero for missing nutrient")
        func testTotalDailyAmountMissingNutrient() {
            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]
            let supplement = Supplement(
                name: "Test",
                servingSize: "1 pill",
                nutrients: nutrients
            )

            let dailyAmount = supplement.totalDailyAmount(for: .vitaminD)
            #expect(dailyAmount == 0)
        }
    }

    // MARK: - Active State Tests

    @Suite("Active State Tests")
    struct ActiveStateTests {

        @Test("Supplement defaults to active")
        func testDefaultActive() {
            let supplement = Supplement(name: "Test", servingSize: "1 pill")
            #expect(supplement.isActive == true)
        }

        @Test("Can create inactive supplement")
        func testInactiveSupplement() {
            let supplement = Supplement(
                name: "Test",
                servingSize: "1 pill",
                isActive: false
            )
            #expect(supplement.isActive == false)
        }

        @Test("Can toggle active state")
        func testToggleActive() {
            var supplement = Supplement(name: "Test", servingSize: "1 pill")
            #expect(supplement.isActive == true)

            supplement.isActive = false
            #expect(supplement.isActive == false)

            supplement.isActive = true
            #expect(supplement.isActive == true)
        }
    }

    // MARK: - SwiftData Persistence Tests

    @Suite("SwiftData Persistence Tests")
    struct PersistenceTests {

        @Test("Supplement can be saved and fetched from SwiftData")
        func testPersistence() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: Supplement.self,
                configurations: config
            )
            let context = ModelContext(container)

            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]
            let supplement = Supplement(
                name: "Test Vitamin",
                brand: "TestBrand",
                servingSize: "1 tablet",
                nutrients: nutrients
            )

            // Act
            context.insert(supplement)
            try context.save()

            let descriptor = FetchDescriptor<Supplement>()
            let fetched = try context.fetch(descriptor)

            // Assert
            #expect(fetched.count == 1)
            #expect(fetched.first?.name == "Test Vitamin")
            #expect(fetched.first?.brand == "TestBrand")
            #expect(fetched.first?.nutrients.count == 1)
        }

        @Test("Multiple supplements can be persisted")
        func testMultiplePersistence() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: Supplement.self,
                configurations: config
            )
            let context = ModelContext(container)

            let supplement1 = Supplement(name: "Vitamin C", servingSize: "1 tablet")
            let supplement2 = Supplement(name: "Vitamin D", servingSize: "1 capsule")
            let supplement3 = Supplement(name: "Magnesium", servingSize: "2 pills")

            context.insert(supplement1)
            context.insert(supplement2)
            context.insert(supplement3)
            try context.save()

            let descriptor = FetchDescriptor<Supplement>()
            let fetched = try context.fetch(descriptor)

            #expect(fetched.count == 3)
        }

        @Test("Supplement can be updated in SwiftData")
        func testUpdate() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: Supplement.self,
                configurations: config
            )
            let context = ModelContext(container)

            let supplement = Supplement(name: "Original", servingSize: "1 tablet")
            context.insert(supplement)
            try context.save()

            // Update
            supplement.name = "Updated"
            supplement.brand = "NewBrand"
            try context.save()

            let descriptor = FetchDescriptor<Supplement>()
            let fetched = try context.fetch(descriptor)

            #expect(fetched.count == 1)
            #expect(fetched.first?.name == "Updated")
            #expect(fetched.first?.brand == "NewBrand")
        }

        @Test("Supplement can be deleted from SwiftData")
        func testDelete() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: Supplement.self,
                configurations: config
            )
            let context = ModelContext(container)

            let supplement = Supplement(name: "ToDelete", servingSize: "1 tablet")
            context.insert(supplement)
            try context.save()

            context.delete(supplement)
            try context.save()

            let descriptor = FetchDescriptor<Supplement>()
            let fetched = try context.fetch(descriptor)

            #expect(fetched.count == 0)
        }
    }

    // MARK: - Edge Cases Tests

    @Suite("Edge Cases Tests")
    struct EdgeCasesTests {

        @Test("Supplement handles empty name")
        func testEmptyName() {
            let supplement = Supplement(name: "", servingSize: "1 pill")
            #expect(supplement.name == "")
        }

        @Test("Supplement handles very long name")
        func testLongName() {
            let longName = String(repeating: "A", count: 1000)
            let supplement = Supplement(name: longName, servingSize: "1 pill")
            #expect(supplement.name.count == 1000)
        }

        @Test("Supplement handles zero servings per day")
        func testZeroServingsPerDay() {
            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]
            let supplement = Supplement(
                name: "Test",
                servingSize: "1 pill",
                servingsPerDay: 0,
                nutrients: nutrients
            )

            let dailyAmount = supplement.totalDailyAmount(for: .vitaminC)
            #expect(dailyAmount == 0)
        }

        @Test("Supplement handles large servings per day")
        func testLargeServingsPerDay() {
            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]
            let supplement = Supplement(
                name: "Test",
                servingSize: "1 pill",
                servingsPerDay: 10,
                nutrients: nutrients
            )

            let dailyAmount = supplement.totalDailyAmount(for: .vitaminC)
            #expect(dailyAmount == 1000)
        }

        @Test("Supplement handles empty nutrients array")
        func testEmptyNutrients() {
            let supplement = Supplement(
                name: "Test",
                servingSize: "1 pill",
                nutrients: []
            )

            #expect(supplement.nutrients.isEmpty)
            #expect(supplement.totalDailyAmount(for: .vitaminC) == 0)
        }
    }

    // MARK: - Identifiable Tests

    @Suite("Identifiable Tests")
    struct IdentifiableTests {

        @Test("Supplement conforms to Identifiable")
        func testIdentifiable() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: Supplement.self,
                configurations: config
            )
            let context = ModelContext(container)

            let supplement = Supplement(name: "Test", servingSize: "1 pill")
            context.insert(supplement)
            try context.save()

            // PersistentIdentifier should be available after insertion
            let id = supplement.id
            #expect(id != nil)
        }
    }
}
