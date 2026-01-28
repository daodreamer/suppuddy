//
//  IntakeRecordTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("IntakeRecord Tests")
struct IntakeRecordTests {

    // MARK: - TimeOfDay Tests

    @Suite("TimeOfDay Tests")
    struct TimeOfDayTests {

        @Test("TimeOfDay has four cases")
        func testTimeOfDayCases() {
            let allCases = TimeOfDay.allCases
            #expect(allCases.count == 4)
            #expect(allCases.contains(.morning))
            #expect(allCases.contains(.noon))
            #expect(allCases.contains(.evening))
            #expect(allCases.contains(.night))
        }

        @Test("TimeOfDay has correct display names")
        func testTimeOfDayDisplayNames() {
            #expect(TimeOfDay.morning.displayName == "早晨")
            #expect(TimeOfDay.noon.displayName == "中午")
            #expect(TimeOfDay.evening.displayName == "傍晚")
            #expect(TimeOfDay.night.displayName == "晚上")
        }

        @Test("TimeOfDay is Codable")
        func testTimeOfDayCodable() throws {
            let original = TimeOfDay.morning
            let encoded = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(TimeOfDay.self, from: encoded)
            #expect(decoded == original)
        }
    }

    // MARK: - Initialization Tests

    @Suite("Initialization Tests")
    struct InitializationTests {

        @Test("IntakeRecord initializes with minimum required fields")
        func testMinimumInitialization() {
            let date = Date()
            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]

            let record = IntakeRecord(
                supplementName: "Vitamin C",
                date: date,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: nutrients
            )

            #expect(record.supplementName == "Vitamin C")
            #expect(record.timeOfDay == .morning)
            #expect(record.servingsTaken == 1)
            #expect(record.nutrients.count == 1)
            #expect(record.supplement == nil)
            #expect(record.notes == nil)
        }

        @Test("IntakeRecord initializes with all fields")
        func testFullInitialization() {
            let date = Date()
            let nutrients = [
                Nutrient(type: .vitaminC, amount: 100),
                Nutrient(type: .vitaminD, amount: 20)
            ]

            let record = IntakeRecord(
                supplementName: "Multi-Vitamin",
                date: date,
                timeOfDay: .evening,
                servingsTaken: 2,
                nutrients: nutrients,
                notes: "Take with food"
            )

            #expect(record.supplementName == "Multi-Vitamin")
            #expect(record.timeOfDay == .evening)
            #expect(record.servingsTaken == 2)
            #expect(record.nutrients.count == 2)
            #expect(record.notes == "Take with food")
        }

        @Test("IntakeRecord sets createdAt on initialization")
        func testCreatedAtSet() {
            let beforeCreation = Date()

            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )

            let afterCreation = Date()
            #expect(record.createdAt >= beforeCreation)
            #expect(record.createdAt <= afterCreation)
        }
    }

    // MARK: - Nutrient Calculation Tests

    @Suite("Nutrient Calculation Tests")
    struct NutrientCalculationTests {

        @Test("totalAmount returns correct amount for existing nutrient")
        func testTotalAmountForExistingNutrient() {
            let nutrients = [
                Nutrient(type: .vitaminC, amount: 100),
                Nutrient(type: .vitaminD, amount: 20)
            ]

            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 2,
                nutrients: nutrients
            )

            // Total = amount * servingsTaken
            #expect(record.totalAmount(for: .vitaminC) == 200)
            #expect(record.totalAmount(for: .vitaminD) == 40)
        }

        @Test("totalAmount returns 0 for non-existing nutrient")
        func testTotalAmountForNonExistingNutrient() {
            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]

            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: nutrients
            )

            #expect(record.totalAmount(for: .vitaminD) == 0)
        }

        @Test("allNutrientsTotalAmounts returns dictionary of all nutrients")
        func testAllNutrientsTotalAmounts() {
            let nutrients = [
                Nutrient(type: .vitaminC, amount: 100),
                Nutrient(type: .vitaminD, amount: 20),
                Nutrient(type: .calcium, amount: 500)
            ]

            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 2,
                nutrients: nutrients
            )

            let totals = record.allNutrientsTotalAmounts()
            #expect(totals.count == 3)
            #expect(totals[.vitaminC] == 200)
            #expect(totals[.vitaminD] == 40)
            #expect(totals[.calcium] == 1000)
        }
    }

    // MARK: - Date Tests

    @Suite("Date Tests")
    struct DateTests {

        @Test("isSameDay returns true for same day")
        func testIsSameDayTrue() {
            let calendar = Calendar.current
            let date1 = calendar.date(from: DateComponents(year: 2026, month: 1, day: 26, hour: 9))!
            let date2 = calendar.date(from: DateComponents(year: 2026, month: 1, day: 26, hour: 18))!

            let record = IntakeRecord(
                supplementName: "Test",
                date: date1,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )

            #expect(record.isSameDay(as: date2))
        }

        @Test("isSameDay returns false for different day")
        func testIsSameDayFalse() {
            let calendar = Calendar.current
            let date1 = calendar.date(from: DateComponents(year: 2026, month: 1, day: 26))!
            let date2 = calendar.date(from: DateComponents(year: 2026, month: 1, day: 27))!

            let record = IntakeRecord(
                supplementName: "Test",
                date: date1,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )

            #expect(!record.isSameDay(as: date2))
        }
    }

    // MARK: - SwiftData Persistence Tests

    @Suite("Persistence Tests")
    struct PersistenceTests {

        @MainActor
        @Test("IntakeRecord can be saved and fetched")
        func testSaveAndFetch() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)

            let nutrients = [Nutrient(type: .vitaminC, amount: 100)]
            let record = IntakeRecord(
                supplementName: "Vitamin C",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: nutrients
            )

            context.insert(record)
            try context.save()

            let descriptor = FetchDescriptor<IntakeRecord>()
            let fetched = try context.fetch(descriptor)

            #expect(fetched.count == 1)
            #expect(fetched.first?.supplementName == "Vitamin C")
            #expect(fetched.first?.nutrients.count == 1)
        }

        @MainActor
        @Test("IntakeRecord persists nutrients correctly")
        func testNutrientsPersistence() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)

            let nutrients = [
                Nutrient(type: .vitaminC, amount: 100),
                Nutrient(type: .vitaminD, amount: 20)
            ]
            let record = IntakeRecord(
                supplementName: "Multi",
                date: Date(),
                timeOfDay: .noon,
                servingsTaken: 2,
                nutrients: nutrients
            )

            context.insert(record)
            try context.save()

            let descriptor = FetchDescriptor<IntakeRecord>()
            let fetched = try context.fetch(descriptor)

            #expect(fetched.first?.nutrients.count == 2)
            #expect(fetched.first?.nutrients.contains(where: { $0.type == .vitaminC && $0.amount == 100 }) ?? false)
            #expect(fetched.first?.nutrients.contains(where: { $0.type == .vitaminD && $0.amount == 20 }) ?? false)
        }

        @MainActor
        @Test("IntakeRecord can be deleted")
        func testDelete() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)

            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )

            context.insert(record)
            try context.save()

            context.delete(record)
            try context.save()

            let descriptor = FetchDescriptor<IntakeRecord>()
            let fetched = try context.fetch(descriptor)

            #expect(fetched.isEmpty)
        }
    }

    // MARK: - Supplement Association Tests

    @Suite("Supplement Association Tests")
    struct SupplementAssociationTests {

        @MainActor
        @Test("IntakeRecord can be associated with Supplement")
        func testSupplementAssociation() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)

            let supplement = Supplement(
                name: "Vitamin C Complex",
                servingSize: "1 tablet",
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            context.insert(supplement)
            try context.save()

            let record = IntakeRecord(
                supplement: supplement,
                supplementName: supplement.name,
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: supplement.nutrients
            )

            context.insert(record)
            try context.save()

            let descriptor = FetchDescriptor<IntakeRecord>()
            let fetched = try context.fetch(descriptor)

            #expect(fetched.first?.supplement?.name == "Vitamin C Complex")
        }

        @MainActor
        @Test("IntakeRecord retains data when Supplement is deleted")
        func testRetainsDataAfterSupplementDeletion() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)

            let supplement = Supplement(
                name: "Vitamin D3",
                servingSize: "1 capsule",
                nutrients: [Nutrient(type: .vitaminD, amount: 50)]
            )
            context.insert(supplement)
            try context.save()

            let record = IntakeRecord(
                supplement: supplement,
                supplementName: supplement.name,
                date: Date(),
                timeOfDay: .evening,
                servingsTaken: 1,
                nutrients: supplement.nutrients
            )

            context.insert(record)
            try context.save()

            // Delete the supplement
            context.delete(supplement)
            try context.save()

            // Record should still exist with snapshot data
            let descriptor = FetchDescriptor<IntakeRecord>()
            let fetched = try context.fetch(descriptor)

            #expect(fetched.count == 1)
            #expect(fetched.first?.supplementName == "Vitamin D3")
            #expect(fetched.first?.nutrients.count == 1)
            #expect(fetched.first?.supplement == nil) // Association is now nil
        }
    }
}
