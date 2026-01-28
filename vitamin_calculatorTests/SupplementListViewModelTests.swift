//
//  SupplementListViewModelTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("SupplementListViewModel Tests")
struct SupplementListViewModelTests {

    // MARK: - Initialization Tests

    @Suite("Initialization Tests")
    struct InitializationTests {

        @MainActor
        @Test("ViewModel initializes with empty supplements list")
        func testInitialState() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let viewModel = SupplementListViewModel(repository: repository)

            #expect(viewModel.supplements.isEmpty)
            #expect(viewModel.isLoading == false)
            #expect(viewModel.errorMessage == nil)
            #expect(viewModel.searchQuery == "")
        }
    }

    // MARK: - Load Supplements Tests

    @Suite("Load Supplements Tests")
    struct LoadTests {

        @MainActor
        @Test("Load supplements populates the list")
        func testLoadSupplements() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            try await repository.save(Supplement(name: "Vitamin C", servingSize: "1 tablet"))
            try await repository.save(Supplement(name: "Vitamin D", servingSize: "1 capsule"))

            let viewModel = SupplementListViewModel(repository: repository)
            await viewModel.loadSupplements()

            #expect(viewModel.supplements.count == 2)
        }

        @MainActor
        @Test("Load supplements sets loading state correctly")
        func testLoadingSate() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let viewModel = SupplementListViewModel(repository: repository)

            #expect(viewModel.isLoading == false)
            await viewModel.loadSupplements()
            #expect(viewModel.isLoading == false)
        }
    }

    // MARK: - Search Tests

    @Suite("Search Tests")
    struct SearchTests {

        @MainActor
        @Test("Search filters supplements by query")
        func testSearch() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            try await repository.save(Supplement(name: "Vitamin C", servingSize: "1 tablet"))
            try await repository.save(Supplement(name: "Vitamin D", servingSize: "1 capsule"))
            try await repository.save(Supplement(name: "Magnesium", servingSize: "2 pills"))

            let viewModel = SupplementListViewModel(repository: repository)
            await viewModel.loadSupplements()

            viewModel.searchQuery = "Vitamin"
            await viewModel.search()

            #expect(viewModel.supplements.count == 2)
        }

        @MainActor
        @Test("Empty search query shows all supplements")
        func testEmptySearch() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            try await repository.save(Supplement(name: "Vitamin C", servingSize: "1 tablet"))
            try await repository.save(Supplement(name: "Vitamin D", servingSize: "1 capsule"))

            let viewModel = SupplementListViewModel(repository: repository)
            viewModel.searchQuery = ""
            await viewModel.search()

            #expect(viewModel.supplements.count == 2)
        }
    }

    // MARK: - Delete Tests

    @Suite("Delete Tests")
    struct DeleteTests {

        @MainActor
        @Test("Delete removes supplement from list")
        func testDelete() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement = Supplement(name: "To Delete", servingSize: "1 tablet")
            try await repository.save(supplement)

            let viewModel = SupplementListViewModel(repository: repository)
            await viewModel.loadSupplements()
            #expect(viewModel.supplements.count == 1)

            await viewModel.delete(supplement)

            #expect(viewModel.supplements.isEmpty)
        }
    }

    // MARK: - Toggle Active Tests

    @Suite("Toggle Active Tests")
    struct ToggleActiveTests {

        @MainActor
        @Test("Toggle active state of supplement")
        func testToggleActive() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            let supplement = Supplement(name: "Test", servingSize: "1 tablet", isActive: true)
            try await repository.save(supplement)

            let viewModel = SupplementListViewModel(repository: repository)
            await viewModel.loadSupplements()

            await viewModel.toggleActive(supplement)

            #expect(supplement.isActive == false)
        }
    }

    // MARK: - Sort Tests

    @Suite("Sort Tests")
    struct SortTests {

        @MainActor
        @Test("Sort by name ascending")
        func testSortByNameAscending() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            try await repository.save(Supplement(name: "Zinc", servingSize: "1 tablet"))
            try await repository.save(Supplement(name: "Calcium", servingSize: "1 tablet"))

            let viewModel = SupplementListViewModel(repository: repository)
            viewModel.sortOption = .name
            viewModel.sortAscending = true
            await viewModel.loadSupplements()

            #expect(viewModel.supplements[0].name == "Calcium")
            #expect(viewModel.supplements[1].name == "Zinc")
        }

        @MainActor
        @Test("Sort by name descending")
        func testSortByNameDescending() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = SupplementRepository(modelContext: context)

            try await repository.save(Supplement(name: "Zinc", servingSize: "1 tablet"))
            try await repository.save(Supplement(name: "Calcium", servingSize: "1 tablet"))

            let viewModel = SupplementListViewModel(repository: repository)
            viewModel.sortOption = .name
            viewModel.sortAscending = false
            await viewModel.loadSupplements()

            #expect(viewModel.supplements[0].name == "Zinc")
            #expect(viewModel.supplements[1].name == "Calcium")
        }
    }
}
