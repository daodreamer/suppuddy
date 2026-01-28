//
//  SupplementRepositoryTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("SupplementRepository Tests")
struct SupplementRepositoryTests {

    // MARK: - Save Tests

    @Suite("Save Tests")
    struct SaveTests {

        @MainActor
        @Test("Save a single supplement successfully")
        func testSaveSingle() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement = Supplement(name: "Vitamin C", servingSize: "1 tablet")

            try await repository.save(supplement)

            let fetched = try await repository.getAll()
            #expect(fetched.count == 1)
            #expect(fetched.first?.name == "Vitamin C")
        }

        @MainActor
        @Test("Save multiple supplements successfully")
        func testSaveMultiple() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement1 = Supplement(name: "Vitamin C", servingSize: "1 tablet")
            let supplement2 = Supplement(name: "Vitamin D", servingSize: "1 capsule")
            let supplement3 = Supplement(name: "Magnesium", servingSize: "2 pills")

            try await repository.save(supplement1)
            try await repository.save(supplement2)
            try await repository.save(supplement3)

            let fetched = try await repository.getAll()
            #expect(fetched.count == 3)
        }

        @MainActor
        @Test("Save supplement with all fields")
        func testSaveWithAllFields() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let nutrients = [
                Nutrient(type: .vitaminC, amount: 100),
                Nutrient(type: .vitaminD, amount: 20)
            ]
            let supplement = Supplement(
                name: "Multi-Vitamin",
                brand: "HealthPlus",
                servingSize: "2 capsules",
                servingsPerDay: 2,
                nutrients: nutrients,
                notes: "Take with food",
                isActive: true
            )

            try await repository.save(supplement)

            let fetched = try await repository.getAll()
            #expect(fetched.count == 1)
            #expect(fetched.first?.brand == "HealthPlus")
            #expect(fetched.first?.nutrients.count == 2)
            #expect(fetched.first?.notes == "Take with food")
        }
    }

    // MARK: - Fetch Tests

    @Suite("Fetch Tests")
    struct FetchTests {

        @MainActor
        @Test("Get all supplements returns empty array when none exist")
        func testGetAllEmpty() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let fetched = try await repository.getAll()
            #expect(fetched.isEmpty)
        }

        @MainActor
        @Test("Get all supplements returns all saved supplements")
        func testGetAllReturnsAll() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement1 = Supplement(name: "Vitamin C", servingSize: "1 tablet")
            let supplement2 = Supplement(name: "Vitamin D", servingSize: "1 capsule")

            try await repository.save(supplement1)
            try await repository.save(supplement2)

            let fetched = try await repository.getAll()
            #expect(fetched.count == 2)
        }

        @MainActor
        @Test("Get active supplements only")
        func testGetActiveOnly() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let active1 = Supplement(name: "Active 1", servingSize: "1 tablet", isActive: true)
            let active2 = Supplement(name: "Active 2", servingSize: "1 tablet", isActive: true)
            let inactive = Supplement(name: "Inactive", servingSize: "1 tablet", isActive: false)

            try await repository.save(active1)
            try await repository.save(active2)
            try await repository.save(inactive)

            let fetched = try await repository.getActive()
            #expect(fetched.count == 2)
            #expect(fetched.allSatisfy { $0.isActive })
        }

        @MainActor
        @Test("Get supplement by ID")
        func testGetById() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement = Supplement(name: "Target Supplement", servingSize: "1 tablet")
            try await repository.save(supplement)

            let id = supplement.persistentModelID
            let fetched = try await repository.getById(id)

            #expect(fetched != nil)
            #expect(fetched?.name == "Target Supplement")
        }

        @MainActor
        @Test("Get by ID returns nil for non-existent ID")
        func testGetByIdNotFound() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let tempSupplement = Supplement(name: "Temp", servingSize: "1 tablet")
            try await repository.save(tempSupplement)
            let id = tempSupplement.persistentModelID
            try await repository.delete(tempSupplement)

            let fetched = try await repository.getById(id)
            #expect(fetched == nil)
        }
    }

    // MARK: - Update Tests

    @Suite("Update Tests")
    struct UpdateTests {

        @MainActor
        @Test("Update supplement name")
        func testUpdateName() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement = Supplement(name: "Original Name", servingSize: "1 tablet")
            try await repository.save(supplement)

            supplement.name = "Updated Name"
            try await repository.update(supplement)

            let fetched = try await repository.getAll()
            #expect(fetched.first?.name == "Updated Name")
        }

        @MainActor
        @Test("Update sets updatedAt timestamp")
        func testUpdateTimestamp() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement = Supplement(name: "Test", servingSize: "1 tablet")
            try await repository.save(supplement)
            let originalUpdatedAt = supplement.updatedAt

            try await Task.sleep(for: .milliseconds(10))

            supplement.name = "Updated"
            try await repository.update(supplement)

            #expect(supplement.updatedAt > originalUpdatedAt)
        }

        @MainActor
        @Test("Update supplement nutrients")
        func testUpdateNutrients() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement = Supplement(
                name: "Multi",
                servingSize: "1 tablet",
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            try await repository.save(supplement)

            supplement.nutrients = [
                Nutrient(type: .vitaminC, amount: 200),
                Nutrient(type: .vitaminD, amount: 50)
            ]
            try await repository.update(supplement)

            let fetched = try await repository.getAll()
            #expect(fetched.first?.nutrients.count == 2)
            #expect(fetched.first?.nutrients.first(where: { $0.type == .vitaminC })?.amount == 200)
        }
    }

    // MARK: - Delete Tests

    @Suite("Delete Tests")
    struct DeleteTests {

        @MainActor
        @Test("Delete a single supplement")
        func testDeleteSingle() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement = Supplement(name: "To Delete", servingSize: "1 tablet")
            try await repository.save(supplement)

            try await repository.delete(supplement)

            let fetched = try await repository.getAll()
            #expect(fetched.isEmpty)
        }

        @MainActor
        @Test("Delete one of multiple supplements")
        func testDeleteOneOfMany() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement1 = Supplement(name: "Keep 1", servingSize: "1 tablet")
            let supplement2 = Supplement(name: "Delete Me", servingSize: "1 tablet")
            let supplement3 = Supplement(name: "Keep 2", servingSize: "1 tablet")

            try await repository.save(supplement1)
            try await repository.save(supplement2)
            try await repository.save(supplement3)

            try await repository.delete(supplement2)

            let fetched = try await repository.getAll()
            #expect(fetched.count == 2)
            #expect(!fetched.contains(where: { $0.name == "Delete Me" }))
        }

        @MainActor
        @Test("Delete all supplements")
        func testDeleteAll() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement1 = Supplement(name: "Supplement 1", servingSize: "1 tablet")
            let supplement2 = Supplement(name: "Supplement 2", servingSize: "1 tablet")
            let supplement3 = Supplement(name: "Supplement 3", servingSize: "1 tablet")

            try await repository.save(supplement1)
            try await repository.save(supplement2)
            try await repository.save(supplement3)

            try await repository.deleteAll()

            let fetched = try await repository.getAll()
            #expect(fetched.isEmpty)
        }
    }

    // MARK: - Search Tests

    @Suite("Search Tests")
    struct SearchTests {

        @MainActor
        @Test("Search by name")
        func testSearchByName() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            try await repository.save(Supplement(name: "Vitamin C Complex", servingSize: "1 tablet"))
            try await repository.save(Supplement(name: "Vitamin D3", servingSize: "1 capsule"))
            try await repository.save(Supplement(name: "Magnesium Citrate", servingSize: "2 pills"))

            let results = try await repository.search(query: "Vitamin")
            #expect(results.count == 2)
        }

        @MainActor
        @Test("Search by brand")
        func testSearchByBrand() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            try await repository.save(Supplement(name: "Vitamin C", brand: "HealthPlus", servingSize: "1 tablet"))
            try await repository.save(Supplement(name: "Vitamin D", brand: "HealthPlus", servingSize: "1 capsule"))
            try await repository.save(Supplement(name: "Magnesium", brand: "NatureBest", servingSize: "2 pills"))

            let results = try await repository.search(query: "HealthPlus")
            #expect(results.count == 2)
        }

        @MainActor
        @Test("Search is case insensitive")
        func testSearchCaseInsensitive() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            try await repository.save(Supplement(name: "VITAMIN C", servingSize: "1 tablet"))
            try await repository.save(Supplement(name: "vitamin d", servingSize: "1 capsule"))

            let results = try await repository.search(query: "vitamin")
            #expect(results.count == 2)
        }

        @MainActor
        @Test("Search returns empty for no matches")
        func testSearchNoMatches() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            try await repository.save(Supplement(name: "Vitamin C", servingSize: "1 tablet"))

            let results = try await repository.search(query: "Iron")
            #expect(results.isEmpty)
        }

        @MainActor
        @Test("Search with empty query returns all")
        func testSearchEmptyQuery() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            try await repository.save(Supplement(name: "Vitamin C", servingSize: "1 tablet"))
            try await repository.save(Supplement(name: "Vitamin D", servingSize: "1 capsule"))

            let results = try await repository.search(query: "")
            #expect(results.count == 2)
        }
    }

    // MARK: - Sort Tests

    @Suite("Sort Tests")
    struct SortTests {

        @MainActor
        @Test("Get all sorted by name ascending")
        func testSortByNameAscending() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            try await repository.save(Supplement(name: "Zinc", servingSize: "1 tablet"))
            try await repository.save(Supplement(name: "Calcium", servingSize: "1 tablet"))
            try await repository.save(Supplement(name: "Magnesium", servingSize: "1 tablet"))

            let results = try await repository.getAllSorted(by: .name, ascending: true)

            #expect(results.count == 3)
            #expect(results[0].name == "Calcium")
            #expect(results[1].name == "Magnesium")
            #expect(results[2].name == "Zinc")
        }

        @MainActor
        @Test("Get all sorted by name descending")
        func testSortByNameDescending() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            try await repository.save(Supplement(name: "Zinc", servingSize: "1 tablet"))
            try await repository.save(Supplement(name: "Calcium", servingSize: "1 tablet"))
            try await repository.save(Supplement(name: "Magnesium", servingSize: "1 tablet"))

            let results = try await repository.getAllSorted(by: .name, ascending: false)

            #expect(results.count == 3)
            #expect(results[0].name == "Zinc")
            #expect(results[1].name == "Magnesium")
            #expect(results[2].name == "Calcium")
        }

        @MainActor
        @Test("Get all sorted by creation date ascending")
        func testSortByCreatedAtAscending() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement1 = Supplement(name: "First", servingSize: "1 tablet")
            try await Task.sleep(for: .milliseconds(10))
            let supplement2 = Supplement(name: "Second", servingSize: "1 tablet")
            try await Task.sleep(for: .milliseconds(10))
            let supplement3 = Supplement(name: "Third", servingSize: "1 tablet")

            try await repository.save(supplement3)
            try await repository.save(supplement1)
            try await repository.save(supplement2)

            let results = try await repository.getAllSorted(by: .createdAt, ascending: true)

            #expect(results.count == 3)
            #expect(results[0].name == "First")
            #expect(results[1].name == "Second")
            #expect(results[2].name == "Third")
        }

        @MainActor
        @Test("Get all sorted by creation date descending")
        func testSortByCreatedAtDescending() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement1 = Supplement(name: "First", servingSize: "1 tablet")
            try await Task.sleep(for: .milliseconds(10))
            let supplement2 = Supplement(name: "Second", servingSize: "1 tablet")
            try await Task.sleep(for: .milliseconds(10))
            let supplement3 = Supplement(name: "Third", servingSize: "1 tablet")

            try await repository.save(supplement3)
            try await repository.save(supplement1)
            try await repository.save(supplement2)

            let results = try await repository.getAllSorted(by: .createdAt, ascending: false)

            #expect(results.count == 3)
            #expect(results[0].name == "Third")
            #expect(results[1].name == "Second")
            #expect(results[2].name == "First")
        }
    }
}
