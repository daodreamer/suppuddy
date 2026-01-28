import Testing
import SwiftData
import Foundation
@testable import vitamin_calculator

// MARK: - Test Helpers (Module Level)

/// Mock OpenFoodFactsAPI for testing
actor MockOpenFoodFactsAPI: ProductAPIProtocol {
    var mockProduct: ScannedProduct?
    var mockSearchResult: ProductSearchResult?
    var shouldThrowError: Error?

    func getProduct(barcode: String) async throws -> ScannedProduct? {
        if let error = shouldThrowError {
            throw error
        }
        return mockProduct
    }

    func searchProducts(query: String, page: Int, pageSize: Int) async throws -> ProductSearchResult {
        if let error = shouldThrowError {
            throw error
        }
        guard let result = mockSearchResult else {
            throw OpenFoodFactsError.invalidResponse
        }
        return result
    }

    func updateMockProduct(_ product: ScannedProduct?) {
        mockProduct = product
    }

    func updateSearchResult(_ result: ProductSearchResult?) {
        mockSearchResult = result
    }

    func setError(_ error: Error?) {
        shouldThrowError = error
    }
}

/// 创建测试用的内存数据库配置
@MainActor
fileprivate func makeTestContext() throws -> ModelContext {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: ScanHistory.self, Supplement.self,
        configurations: config
    )
    return ModelContext(container)
}

/// ProductLookupService 测试套件
@Suite("ProductLookupService Tests")
struct ProductLookupServiceTests {

    // MARK: - Lookup by Barcode Tests

    @Suite("Barcode Lookup Tests")
    struct BarcodeLookupTests {

        @Test("Should return cached product when available")
        @MainActor
        func testLookupWithCache() async throws {
            // Arrange
            let context = try makeTestContext()
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let mockAPI = MockOpenFoodFactsAPI()
            let service = ProductLookupService(
                api: mockAPI,
                historyRepository: historyRepo
            )

            // Create cached product
            let cachedProduct = ScannedProduct(
                barcode: "1234567890123",
                name: "Cached Product",
                brand: "Test Brand",
                imageUrl: nil,
                servingSize: "1 tablet",
                nutrients: []
            )

            let history = ScanHistory(
                barcode: "1234567890123",
                productName: "Cached Product",
                brand: "Test Brand",
                imageUrl: nil,
                wasSuccessful: true
            )
            history.cachedProduct = cachedProduct
            try await historyRepo.save(history)

            // Act
            let result = try await service.lookupByBarcode("1234567890123")

            // Assert
            #expect(result != nil)
            #expect(result?.name == "Cached Product")
            #expect(result?.barcode == "1234567890123")
        }

        @Test("Should query API when cache miss")
        @MainActor
        func testLookupWithAPICacheMiss() async throws {
            // Arrange
            let context = try makeTestContext()
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let mockAPI = MockOpenFoodFactsAPI()

            let apiProduct = ScannedProduct(
                barcode: "9876543210987",
                name: "API Product",
                brand: "API Brand",
                imageUrl: nil,
                servingSize: "1 capsule",
                nutrients: []
            )
            await mockAPI.updateMockProduct(apiProduct)

            let service = ProductLookupService(
                api: mockAPI,
                historyRepository: historyRepo
            )

            // Act
            let result = try await service.lookupByBarcode("9876543210987")

            // Assert
            #expect(result != nil)
            #expect(result?.name == "API Product")
            #expect(result?.barcode == "9876543210987")
        }

        @Test("Should return nil when product not found")
        @MainActor
        func testLookupProductNotFound() async throws {
            // Arrange
            let context = try makeTestContext()
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let mockAPI = MockOpenFoodFactsAPI()
            await mockAPI.updateMockProduct(nil)

            let service = ProductLookupService(
                api: mockAPI,
                historyRepository: historyRepo
            )

            // Act
            let result = try await service.lookupByBarcode("0000000000000")

            // Assert
            #expect(result == nil)
        }

        @Test("Should handle network errors gracefully")
        @MainActor
        func testLookupNetworkError() async throws {
            // Arrange
            let context = try makeTestContext()
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let mockAPI = MockOpenFoodFactsAPI()
            await mockAPI.setError(OpenFoodFactsError.networkError(NSError(domain: "Test", code: -1)))

            let service = ProductLookupService(
                api: mockAPI,
                historyRepository: historyRepo
            )

            // Act & Assert
            await #expect(throws: OpenFoodFactsError.self) {
                _ = try await service.lookupByBarcode("1234567890123")
            }
        }
    }

    // MARK: - Search Tests

    @Suite("Product Search Tests")
    struct ProductSearchTests {

        @Test("Should search products with query")
        @MainActor
        func testSearchProducts() async throws {
            // Arrange
            let context = try makeTestContext()
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let mockAPI = MockOpenFoodFactsAPI()

            let searchResult = ProductSearchResult(
                products: [
                    ScannedProduct(barcode: "111", name: "Vitamin C", brand: "Brand A", imageUrl: nil, servingSize: "1 tablet", nutrients: []),
                    ScannedProduct(barcode: "222", name: "Vitamin D", brand: "Brand B", imageUrl: nil, servingSize: "1 capsule", nutrients: [])
                ],
                totalCount: 2,
                page: 1,
                pageSize: 10
            )
            await mockAPI.updateSearchResult(searchResult)

            let service = ProductLookupService(
                api: mockAPI,
                historyRepository: historyRepo
            )

            // Act
            let result = try await service.searchProducts(query: "vitamin", page: 1)

            // Assert
            #expect(result.products.count == 2)
            #expect(result.products[0].name == "Vitamin C")
            #expect(result.products[1].name == "Vitamin D")
            #expect(result.totalCount == 2)
        }

        @Test("Should handle empty search results")
        @MainActor
        func testSearchProductsEmpty() async throws {
            // Arrange
            let context = try makeTestContext()
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let mockAPI = MockOpenFoodFactsAPI()

            let emptyResult = ProductSearchResult(
                products: [],
                totalCount: 0,
                page: 1,
                pageSize: 10
            )
            await mockAPI.updateSearchResult(emptyResult)

            let service = ProductLookupService(
                api: mockAPI,
                historyRepository: historyRepo
            )

            // Act
            let result = try await service.searchProducts(query: "nonexistent", page: 1)

            // Assert
            #expect(result.products.isEmpty)
            #expect(result.totalCount == 0)
        }
    }

    // MARK: - Scan History Tests

    @Suite("Scan History Management Tests")
    struct ScanHistoryTests {

        @Test("Should save successful scan to history")
        @MainActor
        func testSaveSuccessfulScan() async throws {
            // Arrange
            let context = try makeTestContext()
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let mockAPI = MockOpenFoodFactsAPI()
            let service = ProductLookupService(
                api: mockAPI,
                historyRepository: historyRepo
            )

            let product = ScannedProduct(
                barcode: "1234567890123",
                name: "Test Product",
                brand: "Test Brand",
                imageUrl: nil,
                servingSize: "1 tablet",
                nutrients: []
            )

            // Act
            try await service.saveScanHistory(
                barcode: "1234567890123",
                product: product,
                wasSuccessful: true
            )

            // Assert
            let history = try await historyRepo.getByBarcode("1234567890123")
            #expect(history != nil)
            #expect(history?.wasSuccessful == true)
            #expect(history?.productName == "Test Product")
            #expect(history?.cachedProduct?.name == "Test Product")
        }

        @Test("Should save failed scan to history")
        @MainActor
        func testSaveFailedScan() async throws {
            // Arrange
            let context = try makeTestContext()
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let mockAPI = MockOpenFoodFactsAPI()
            let service = ProductLookupService(
                api: mockAPI,
                historyRepository: historyRepo
            )

            // Act
            try await service.saveScanHistory(
                barcode: "0000000000000",
                product: nil,
                wasSuccessful: false
            )

            // Assert
            let history = try await historyRepo.getByBarcode("0000000000000")
            #expect(history != nil)
            #expect(history?.wasSuccessful == false)
            #expect(history?.cachedProduct == nil)
        }

        @Test("Should retrieve recent scans")
        @MainActor
        func testGetRecentScans() async throws {
            // Arrange
            let context = try makeTestContext()
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let mockAPI = MockOpenFoodFactsAPI()
            let service = ProductLookupService(
                api: mockAPI,
                historyRepository: historyRepo
            )

            // Save multiple scans
            for i in 1...5 {
                let product = ScannedProduct(
                    barcode: "12345678901\(i)",
                    name: "Product \(i)",
                    brand: nil,
                    imageUrl: nil,
                    servingSize: nil,
                    nutrients: []
                )
                try await service.saveScanHistory(
                    barcode: "12345678901\(i)",
                    product: product,
                    wasSuccessful: true
                )
            }

            // Act
            let scans = try await service.getRecentScans()

            // Assert
            #expect(scans.count == 5)
            // Most recent should be first
            #expect(scans[0].productName == "Product 5")
        }

        @Test("Should clear all scan history")
        @MainActor
        func testClearHistory() async throws {
            // Arrange
            let context = try makeTestContext()
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let mockAPI = MockOpenFoodFactsAPI()
            let service = ProductLookupService(
                api: mockAPI,
                historyRepository: historyRepo
            )

            // Save some scans
            let product = ScannedProduct(
                barcode: "1234567890123",
                name: "Test Product",
                brand: nil,
                imageUrl: nil,
                servingSize: nil,
                nutrients: []
            )
            try await service.saveScanHistory(
                barcode: "1234567890123",
                product: product,
                wasSuccessful: true
            )

            // Act
            try await service.clearHistory()

            // Assert
            let scans = try await service.getRecentScans()
            #expect(scans.isEmpty)
        }
    }

    // MARK: - Conversion Tests

    @Suite("Supplement Conversion Tests")
    struct SupplementConversionTests {

        @Test("Should convert scanned product to local supplement")
        @MainActor
        func testSaveAsLocalSupplement() async throws {
            // Arrange
            let context = try makeTestContext()
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let supplementRepo = SupplementRepository(modelContext: context)
            let mockAPI = MockOpenFoodFactsAPI()
            let service = ProductLookupService(
                api: mockAPI,
                historyRepository: historyRepo,
                supplementRepository: supplementRepo
            )

            let product = ScannedProduct(
                barcode: "1234567890123",
                name: "Vitamin C Supplement",
                brand: "Health Brand",
                imageUrl: nil,
                servingSize: "1 tablet",
                nutrients: [
                    ScannedNutrient(name: "vitamin-c", amount: 100, unit: "mg")
                ]
            )

            // Act
            let supplement = try await service.saveAsLocalSupplement(
                product,
                servingsPerDay: 2
            )

            // Assert
            #expect(supplement.name == "Vitamin C Supplement")
            #expect(supplement.brand == "Health Brand")
            #expect(supplement.servingsPerDay == 2)
            #expect(supplement.nutrients.count > 0)

            // Verify it was saved
            let saved = try await supplementRepo.getAll()
            #expect(saved.count == 1)
            #expect(saved.first?.name == "Vitamin C Supplement")
        }

        @Test("Should handle product with no mappable nutrients")
        @MainActor
        func testSaveProductWithNoNutrients() async throws {
            // Arrange
            let context = try makeTestContext()
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let supplementRepo = SupplementRepository(modelContext: context)
            let mockAPI = MockOpenFoodFactsAPI()
            let service = ProductLookupService(
                api: mockAPI,
                historyRepository: historyRepo,
                supplementRepository: supplementRepo
            )

            let product = ScannedProduct(
                barcode: "1234567890123",
                name: "Unknown Product",
                brand: nil,
                imageUrl: nil,
                servingSize: nil,
                nutrients: []
            )

            // Act
            let supplement = try await service.saveAsLocalSupplement(
                product,
                servingsPerDay: 1
            )

            // Assert
            #expect(supplement.name == "Unknown Product")
            #expect(supplement.nutrients.isEmpty)
        }
    }
}
