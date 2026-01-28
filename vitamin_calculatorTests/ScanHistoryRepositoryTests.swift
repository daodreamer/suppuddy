//
//  ScanHistoryRepositoryTests.swift
//  vitamin_calculatorTests
//
//  Created by TDD on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("ScanHistoryRepository Tests")
struct ScanHistoryRepositoryTests {

    // MARK: - Save Tests

    @Suite("Save Tests")
    struct SaveTests {

        @MainActor
        @Test("Save a single scan history record")
        func testSaveSingle() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            let history = ScanHistory(
                barcode: "1234567890123",
                productName: "Test Product",
                brand: "Brand",
                imageUrl: nil,
                wasSuccessful: true
            )

            // Act
            try await repository.save(history)

            // Assert
            let fetched = try await repository.getAll()
            #expect(fetched.count == 1)
            #expect(fetched.first?.barcode == "1234567890123")
        }

        @MainActor
        @Test("Save multiple scan history records")
        func testSaveMultiple() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            let history1 = ScanHistory(barcode: "111", productName: "Product 1", brand: nil, imageUrl: nil, wasSuccessful: true)
            let history2 = ScanHistory(barcode: "222", productName: "Product 2", brand: nil, imageUrl: nil, wasSuccessful: true)
            let history3 = ScanHistory(barcode: "333", productName: "Product 3", brand: nil, imageUrl: nil, wasSuccessful: false)

            // Act
            try await repository.save(history1)
            try await repository.save(history2)
            try await repository.save(history3)

            // Assert
            let fetched = try await repository.getAll()
            #expect(fetched.count == 3)
        }
    }

    // MARK: - Fetch Tests

    @Suite("Fetch Tests")
    struct FetchTests {

        @MainActor
        @Test("Get all scan history records")
        func testGetAll() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            let history1 = ScanHistory(barcode: "111", productName: "Product 1", brand: nil, imageUrl: nil, wasSuccessful: true)
            let history2 = ScanHistory(barcode: "222", productName: "Product 2", brand: nil, imageUrl: nil, wasSuccessful: true)
            try await repository.save(history1)
            try await repository.save(history2)

            // Act
            let results = try await repository.getAll()

            // Assert
            #expect(results.count == 2)
        }

        @MainActor
        @Test("Get recent scan history with limit")
        func testGetRecent() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            // Create 5 histories with delays to ensure different timestamps
            for i in 1...5 {
                let history = ScanHistory(barcode: "\(i)", productName: "Product \(i)", brand: nil, imageUrl: nil, wasSuccessful: true)
                try await repository.save(history)
                try await Task.sleep(for: .milliseconds(10))
            }

            // Act - Get only 3 most recent
            let recent = try await repository.getRecent(limit: 3)

            // Assert
            #expect(recent.count == 3)
            // Should be in reverse chronological order (most recent first)
            #expect(recent[0].productName == "Product 5")
            #expect(recent[1].productName == "Product 4")
            #expect(recent[2].productName == "Product 3")
        }

        @MainActor
        @Test("Get scan history by barcode")
        func testGetByBarcode() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            let history1 = ScanHistory(barcode: "AAA111", productName: "Product A", brand: nil, imageUrl: nil, wasSuccessful: true)
            let history2 = ScanHistory(barcode: "BBB222", productName: "Product B", brand: nil, imageUrl: nil, wasSuccessful: true)
            try await repository.save(history1)
            try await repository.save(history2)

            // Act
            let found = try await repository.getByBarcode("AAA111")

            // Assert
            #expect(found != nil)
            #expect(found?.productName == "Product A")
        }

        @MainActor
        @Test("Get by barcode returns nil when not found")
        func testGetByBarcodeNotFound() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            // Act
            let found = try await repository.getByBarcode("NONEXISTENT")

            // Assert
            #expect(found == nil)
        }

        @MainActor
        @Test("Get by barcode returns most recent when multiple exist")
        func testGetByBarcodeMostRecent() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            let history1 = ScanHistory(barcode: "111", productName: "First Scan", brand: nil, imageUrl: nil, wasSuccessful: true)
            try await repository.save(history1)
            try await Task.sleep(for: .milliseconds(10))

            let history2 = ScanHistory(barcode: "111", productName: "Second Scan", brand: nil, imageUrl: nil, wasSuccessful: true)
            try await repository.save(history2)

            // Act
            let found = try await repository.getByBarcode("111")

            // Assert
            #expect(found?.productName == "Second Scan")
        }
    }

    // MARK: - Delete Tests

    @Suite("Delete Tests")
    struct DeleteTests {

        @MainActor
        @Test("Delete a single scan history record")
        func testDeleteSingle() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            let history = ScanHistory(barcode: "123", productName: "To Delete", brand: nil, imageUrl: nil, wasSuccessful: true)
            try await repository.save(history)

            // Act
            try await repository.delete(history)

            // Assert
            let fetched = try await repository.getAll()
            #expect(fetched.isEmpty)
        }

        @MainActor
        @Test("Clear all scan history")
        func testClearAll() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            let history1 = ScanHistory(barcode: "111", productName: "Product 1", brand: nil, imageUrl: nil, wasSuccessful: true)
            let history2 = ScanHistory(barcode: "222", productName: "Product 2", brand: nil, imageUrl: nil, wasSuccessful: true)
            let history3 = ScanHistory(barcode: "333", productName: "Product 3", brand: nil, imageUrl: nil, wasSuccessful: true)
            try await repository.save(history1)
            try await repository.save(history2)
            try await repository.save(history3)

            // Act
            try await repository.clearAll()

            // Assert
            let fetched = try await repository.getAll()
            #expect(fetched.isEmpty)
        }
    }

    // MARK: - Pruning Tests

    @Suite("Pruning Tests")
    struct PruningTests {

        @MainActor
        @Test("Prune old entries keeps only N most recent")
        func testPruneOldEntries() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            // Create 25 histories (exceeds maxHistoryCount of 20)
            for i in 1...25 {
                let history = ScanHistory(barcode: "\(i)", productName: "Product \(i)", brand: nil, imageUrl: nil, wasSuccessful: true)
                try await repository.save(history)
                try await Task.sleep(for: .milliseconds(5))
            }

            // Act
            try await repository.pruneOldEntries()

            // Assert
            let remaining = try await repository.getAll()
            #expect(remaining.count == 20)

            // Verify the oldest 5 were deleted (Product 1-5)
            // and newest 20 remain (Product 6-25)
            let remainingNames = remaining.map { $0.productName }.sorted()
            #expect(!remainingNames.contains("Product 1"))
            #expect(!remainingNames.contains("Product 5"))
            #expect(remainingNames.contains("Product 25"))
        }

        @MainActor
        @Test("Prune does nothing when under limit")
        func testPruneUnderLimit() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            // Create only 5 histories (under limit of 20)
            for i in 1...5 {
                let history = ScanHistory(barcode: "\(i)", productName: "Product \(i)", brand: nil, imageUrl: nil, wasSuccessful: true)
                try await repository.save(history)
            }

            // Act
            try await repository.pruneOldEntries()

            // Assert
            let remaining = try await repository.getAll()
            #expect(remaining.count == 5)
        }
    }

    // MARK: - Edge Case Tests

    @Suite("Edge Case Tests")
    struct EdgeCaseTests {

        @MainActor
        @Test("Get all returns empty array when no records")
        func testGetAllEmpty() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            // Act
            let results = try await repository.getAll()

            // Assert
            #expect(results.isEmpty)
        }

        @MainActor
        @Test("Get recent with limit larger than available records")
        func testGetRecentLargeLimit() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            // Create only 3 histories
            for i in 1...3 {
                let history = ScanHistory(barcode: "\(i)", productName: "Product \(i)", brand: nil, imageUrl: nil, wasSuccessful: true)
                try await repository.save(history)
            }

            // Act - Request 10 but only 3 exist
            let recent = try await repository.getRecent(limit: 10)

            // Assert
            #expect(recent.count == 3)
        }

        @MainActor
        @Test("Get recent with zero limit returns empty")
        func testGetRecentZeroLimit() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: ScanHistory.self, configurations: config)
            let context = ModelContext(container)
            let repository = ScanHistoryRepository(modelContext: context)

            let history = ScanHistory(barcode: "123", productName: "Product", brand: nil, imageUrl: nil, wasSuccessful: true)
            try await repository.save(history)

            // Act
            let recent = try await repository.getRecent(limit: 0)

            // Assert
            #expect(recent.isEmpty)
        }
    }
}
