//
//  ScanHistoryTests.swift
//  vitamin_calculatorTests
//
//  Created by TDD on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("ScanHistory Model Tests")
struct ScanHistoryTests {

    @Suite("Initialization Tests")
    struct InitializationTests {
        @Test("ScanHistory initializes with all required properties")
        func testScanHistoryInitialization() {
            // Arrange & Act
            let scanHistory = ScanHistory(
                barcode: "1234567890123",
                productName: "Test Product",
                brand: "Test Brand",
                imageUrl: "https://example.com/image.jpg",
                wasSuccessful: true
            )

            // Assert
            #expect(scanHistory.barcode == "1234567890123")
            #expect(scanHistory.productName == "Test Product")
            #expect(scanHistory.brand == "Test Brand")
            #expect(scanHistory.imageUrl == "https://example.com/image.jpg")
            #expect(scanHistory.wasSuccessful == true)
            #expect(scanHistory.scannedAt != nil)
        }

        @Test("ScanHistory initializes with optional nil values")
        func testScanHistoryWithNilOptionals() {
            // Arrange & Act
            let scanHistory = ScanHistory(
                barcode: "9999999999999",
                productName: "Basic Product",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: false
            )

            // Assert
            #expect(scanHistory.barcode == "9999999999999")
            #expect(scanHistory.productName == "Basic Product")
            #expect(scanHistory.brand == nil)
            #expect(scanHistory.imageUrl == nil)
            #expect(scanHistory.wasSuccessful == false)
        }

        @Test("ScanHistory has scannedAt timestamp on creation")
        func testScannedAtTimestamp() {
            // Arrange
            let beforeCreation = Date()

            // Act
            let scanHistory = ScanHistory(
                barcode: "123",
                productName: "Product",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: true
            )
            let afterCreation = Date()

            // Assert
            #expect(scanHistory.scannedAt >= beforeCreation)
            #expect(scanHistory.scannedAt <= afterCreation)
        }
    }

    @Suite("Cached Product Tests")
    struct CachedProductTests {
        @Test("ScanHistory can cache ScannedProduct")
        func testCacheProduct() {
            // Arrange
            let product = ScannedProduct(
                barcode: "123",
                name: "Test Product",
                brand: "Brand",
                imageUrl: nil,
                servingSize: "1 serving",
                nutrients: [ScannedNutrient(name: "vitamin-c", amount: 100, unit: "mg")]
            )
            var scanHistory = ScanHistory(
                barcode: "123",
                productName: "Test Product",
                brand: "Brand",
                imageUrl: nil,
                wasSuccessful: true
            )

            // Act
            scanHistory.cachedProduct = product

            // Assert
            #expect(scanHistory.cachedProduct != nil)
            #expect(scanHistory.cachedProduct?.barcode == "123")
            #expect(scanHistory.cachedProduct?.name == "Test Product")
        }

        @Test("ScanHistory cached product is nil by default")
        func testNoCachedProductByDefault() {
            // Arrange & Act
            let scanHistory = ScanHistory(
                barcode: "999",
                productName: "Product",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: true
            )

            // Assert
            #expect(scanHistory.cachedProduct == nil)
        }

        @Test("ScanHistory can clear cached product")
        func testClearCachedProduct() {
            // Arrange
            let product = ScannedProduct(
                barcode: "456",
                name: "Product",
                brand: nil,
                imageUrl: nil,
                servingSize: nil,
                nutrients: []
            )
            var scanHistory = ScanHistory(
                barcode: "456",
                productName: "Product",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: true
            )
            scanHistory.cachedProduct = product

            // Act
            scanHistory.cachedProduct = nil

            // Assert
            #expect(scanHistory.cachedProduct == nil)
        }
    }

    @Suite("SwiftData Persistence Tests")
    struct PersistenceTests {
        @Test("ScanHistory can be persisted to SwiftData")
        func testPersistence() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self,
                configurations: config
            )
            let context = ModelContext(container)

            let scanHistory = ScanHistory(
                barcode: "111222333",
                productName: "Persisted Product",
                brand: "Brand",
                imageUrl: "https://example.com/image.jpg",
                wasSuccessful: true
            )

            // Act
            context.insert(scanHistory)
            try context.save()

            // Assert
            let descriptor = FetchDescriptor<ScanHistory>()
            let results = try context.fetch(descriptor)

            #expect(results.count == 1)
            #expect(results.first?.barcode == "111222333")
            #expect(results.first?.productName == "Persisted Product")
        }

        @Test("Multiple ScanHistory records can be persisted")
        func testMultiplePersistence() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self,
                configurations: config
            )
            let context = ModelContext(container)

            let history1 = ScanHistory(
                barcode: "111",
                productName: "Product 1",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: true
            )
            let history2 = ScanHistory(
                barcode: "222",
                productName: "Product 2",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: false
            )

            // Act
            context.insert(history1)
            context.insert(history2)
            try context.save()

            // Assert
            let descriptor = FetchDescriptor<ScanHistory>()
            let results = try context.fetch(descriptor)

            #expect(results.count == 2)
        }

        @Test("ScanHistory can be deleted from SwiftData")
        func testDeletion() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self,
                configurations: config
            )
            let context = ModelContext(container)

            let scanHistory = ScanHistory(
                barcode: "999",
                productName: "To Delete",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: true
            )
            context.insert(scanHistory)
            try context.save()

            // Act
            context.delete(scanHistory)
            try context.save()

            // Assert
            let descriptor = FetchDescriptor<ScanHistory>()
            let results = try context.fetch(descriptor)

            #expect(results.isEmpty)
        }

        @Test("ScanHistory with cached product can be persisted")
        func testPersistenceWithCachedProduct() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self,
                configurations: config
            )
            let context = ModelContext(container)

            let product = ScannedProduct(
                barcode: "777",
                name: "Cached Product",
                brand: "Brand",
                imageUrl: nil,
                servingSize: "1 tablet",
                nutrients: [
                    ScannedNutrient(name: "vitamin-d", amount: 20, unit: "μg")
                ]
            )
            var scanHistory = ScanHistory(
                barcode: "777",
                productName: "Cached Product",
                brand: "Brand",
                imageUrl: nil,
                wasSuccessful: true
            )
            scanHistory.cachedProduct = product

            // Act
            context.insert(scanHistory)
            try context.save()

            // Assert
            let descriptor = FetchDescriptor<ScanHistory>()
            let results = try context.fetch(descriptor)

            #expect(results.count == 1)
            #expect(results.first?.cachedProduct != nil)
            #expect(results.first?.cachedProduct?.name == "Cached Product")
        }
    }

    @Suite("Sorting and Ordering Tests")
    struct SortingTests {
        @Test("ScanHistory can be sorted by scannedAt descending")
        func testSortByDate() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self,
                configurations: config
            )
            let context = ModelContext(container)

            // Create histories with slight time delays
            let history1 = ScanHistory(
                barcode: "111",
                productName: "First",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: true
            )
            context.insert(history1)
            try context.save()

            // Small delay to ensure different timestamps
            try await Task.sleep(for: .milliseconds(10))

            let history2 = ScanHistory(
                barcode: "222",
                productName: "Second",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: true
            )
            context.insert(history2)
            try context.save()

            try await Task.sleep(for: .milliseconds(10))

            let history3 = ScanHistory(
                barcode: "333",
                productName: "Third",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: true
            )
            context.insert(history3)
            try context.save()

            // Act
            var descriptor = FetchDescriptor<ScanHistory>(
                sortBy: [SortDescriptor(\.scannedAt, order: .reverse)]
            )
            let results = try context.fetch(descriptor)

            // Assert
            #expect(results.count == 3)
            #expect(results[0].productName == "Third") // Most recent
            #expect(results[1].productName == "Second")
            #expect(results[2].productName == "First") // Oldest
        }

        @Test("ScanHistory can be limited to most recent N records")
        func testLimitResults() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self,
                configurations: config
            )
            let context = ModelContext(container)

            // Create 5 histories
            for i in 1...5 {
                let history = ScanHistory(
                    barcode: "\(i)",
                    productName: "Product \(i)",
                    brand: nil,
                    imageUrl: nil,
                    wasSuccessful: true
                )
                context.insert(history)
                try await Task.sleep(for: .milliseconds(5))
            }
            try context.save()

            // Act - Fetch only most recent 3
            var descriptor = FetchDescriptor<ScanHistory>(
                sortBy: [SortDescriptor(\.scannedAt, order: .reverse)]
            )
            descriptor.fetchLimit = 3
            let results = try context.fetch(descriptor)

            // Assert
            #expect(results.count == 3)
        }
    }

    @Suite("Query Tests")
    struct QueryTests {
        @Test("ScanHistory can be queried by barcode")
        func testQueryByBarcode() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self,
                configurations: config
            )
            let context = ModelContext(container)

            let history1 = ScanHistory(
                barcode: "AAA111",
                productName: "Product A",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: true
            )
            let history2 = ScanHistory(
                barcode: "BBB222",
                productName: "Product B",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: true
            )
            context.insert(history1)
            context.insert(history2)
            try context.save()

            // Act
            let predicate = #Predicate<ScanHistory> { $0.barcode == "AAA111" }
            var descriptor = FetchDescriptor<ScanHistory>(predicate: predicate)
            let results = try context.fetch(descriptor)

            // Assert
            #expect(results.count == 1)
            #expect(results.first?.barcode == "AAA111")
            #expect(results.first?.productName == "Product A")
        }

        @Test("ScanHistory can be queried by wasSuccessful")
        func testQueryBySuccess() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self,
                configurations: config
            )
            let context = ModelContext(container)

            let successHistory = ScanHistory(
                barcode: "111",
                productName: "Success",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: true
            )
            let failureHistory = ScanHistory(
                barcode: "222",
                productName: "Failure",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: false
            )
            context.insert(successHistory)
            context.insert(failureHistory)
            try context.save()

            // Act
            let predicate = #Predicate<ScanHistory> { $0.wasSuccessful == true }
            var descriptor = FetchDescriptor<ScanHistory>(predicate: predicate)
            let results = try context.fetch(descriptor)

            // Assert
            #expect(results.count == 1)
            #expect(results.first?.productName == "Success")
        }
    }
}
