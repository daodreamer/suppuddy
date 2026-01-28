//
//  IntegrationTests.swift
//  vitamin_calculatorTests
//
//  Integration tests for Sprint 5 - Barcode Scanning & Product Search
//

import Testing
import SwiftData
import Foundation
@testable import vitamin_calculator

/// Integration tests for complete user workflows
@Suite("Sprint 5 Integration Tests")
struct IntegrationTests {

    // MARK: - Test Helpers

    /// Creates a mock URLSession that returns predefined responses
    final class MockURLSession: URLSessionProtocol {
        var mockData: Data?
        var mockResponse: HTTPURLResponse?
        var mockError: Error?

        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            if let error = mockError {
                throw error
            }
            let response = mockResponse ?? HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (mockData ?? Data(), response)
        }
    }

    // MARK: - Barcode Scanning Flow Tests

    @Suite("Complete Barcode Scanning Flow")
    struct BarcodeScanningFlowTests {

        @Test("Complete scan flow: barcode → API → history → success")
        @MainActor
        func testCompleteScanFlowSuccess() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self, Supplement.self, UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            // Create mock API response
            let testProduct = ScannedProduct(
                barcode: "4006381333931",
                name: "Test Vitamin D3",
                brand: "Test Brand",
                imageUrl: nil,
                servingSize: "1 tablet",
                nutrients: [
                    ScannedNutrient(name: "Vitamin D", amount: 20.0, unit: "μg")
                ]
            )
            let productData = try JSONEncoder().encode(testProduct)

            let mockSession = MockURLSession()
            mockSession.mockData = productData
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://world.openfoodfacts.org/api/v2/product/4006381333931")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )

            let api = OpenFoodFactsAPI(session: mockSession)
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let lookupService = ProductLookupService(api: api, historyRepository: historyRepo)
            let scannerService = BarcodeScannerService()
            let viewModel = BarcodeScannerViewModel(scannerService: scannerService, lookupService: lookupService)

            // Act: Simulate scanning a barcode
            await viewModel.handleScannedBarcode("4006381333931")

            // Assert: Check that product was found
            if case .found(let product) = viewModel.scanState {
                #expect(product.barcode == "4006381333931")
                #expect(product.name == "Test Vitamin D3")
                #expect(product.brand == "Test Brand")
            } else {
                Issue.record("Expected scan state to be .found")
            }

            // Assert: Check that history was saved
            let history = try await historyRepo.getAll()
            #expect(history.count == 1)
            #expect(history.first?.barcode == "4006381333931")
            #expect(history.first?.wasSuccessful == true)
        }

        @Test("Complete scan flow: barcode → API → not found")
        @MainActor
        func testCompleteScanFlowNotFound() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self, Supplement.self, UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let mockSession = MockURLSession()
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://world.openfoodfacts.org/api/v2/product/9999999999999")!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )

            let api = OpenFoodFactsAPI(session: mockSession)
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let lookupService = ProductLookupService(api: api, historyRepository: historyRepo)
            let scannerService = BarcodeScannerService()
            let viewModel = BarcodeScannerViewModel(scannerService: scannerService, lookupService: lookupService)

            // Act
            await viewModel.handleScannedBarcode("9999999999999")

            // Assert: Check that state is notFound
            if case .notFound(let barcode) = viewModel.scanState {
                #expect(barcode == "9999999999999")
            } else {
                Issue.record("Expected scan state to be .notFound")
            }

            // Assert: History should still be saved (but marked as unsuccessful)
            let history = try await historyRepo.getAll()
            #expect(history.count == 1)
            #expect(history.first?.wasSuccessful == false)
        }

        @Test("Scan flow with network error")
        @MainActor
        func testScanFlowWithNetworkError() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self, Supplement.self, UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let mockSession = MockURLSession()
            mockSession.mockError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)

            let api = OpenFoodFactsAPI(session: mockSession)
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let lookupService = ProductLookupService(api: api, historyRepository: historyRepo)
            let scannerService = BarcodeScannerService()
            let viewModel = BarcodeScannerViewModel(scannerService: scannerService, lookupService: lookupService)

            // Act
            await viewModel.handleScannedBarcode("4006381333931")

            // Assert: Check error state
            if case .error(let message) = viewModel.scanState {
                #expect(message.contains("network") || message.contains("Network") || message.contains("error") || message.contains("Error"))
            } else {
                Issue.record("Expected scan state to be .error")
            }
        }
    }

    // MARK: - Product Search Flow Tests

    @Suite("Complete Product Search Flow")
    struct ProductSearchFlowTests {

        @Test("Complete search flow: query → API → results display")
        @MainActor
        func testCompleteSearchFlowSuccess() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self, Supplement.self, UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let testProducts = [
                ScannedProduct(
                    barcode: "1234567890123",
                    name: "Vitamin C 1000mg",
                    brand: "Brand A",
                    imageUrl: nil,
                    servingSize: "1 tablet",
                    nutrients: [
                        ScannedNutrient(name: "Vitamin C", amount: 1000.0, unit: "mg")
                    ]
                ),
                ScannedProduct(
                    barcode: "1234567890124",
                    name: "Vitamin C 500mg",
                    brand: "Brand B",
                    imageUrl: nil,
                    servingSize: "1 tablet",
                    nutrients: [
                        ScannedNutrient(name: "Vitamin C", amount: 500.0, unit: "mg")
                    ]
                )
            ]
            let searchResult = ProductSearchResult(
                products: testProducts,
                totalCount: 2,
                page: 1,
                pageSize: 20
            )
            let searchData = try JSONEncoder().encode(searchResult)

            let mockSession = MockURLSession()
            mockSession.mockData = searchData
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://world.openfoodfacts.org/api/v2/search")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )

            let api = OpenFoodFactsAPI(session: mockSession)
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let lookupService = ProductLookupService(api: api, historyRepository: historyRepo)
            let viewModel = ProductSearchViewModel(lookupService: lookupService)

            // Act: Perform search
            viewModel.searchQuery = "Vitamin C"
            await viewModel.search()

            // Assert: Check results
            #expect(viewModel.searchResults.count == 2)
            #expect(viewModel.searchResults[0].name == "Vitamin C 1000mg")
            #expect(viewModel.searchResults[1].name == "Vitamin C 500mg")
            #expect(!viewModel.isLoading)
            #expect(viewModel.errorMessage == nil)
        }

        @Test("Search flow with empty query")
        @MainActor
        func testSearchFlowWithEmptyQuery() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self, Supplement.self, UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let mockSession = MockURLSession()
            let api = OpenFoodFactsAPI(session: mockSession)
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let lookupService = ProductLookupService(api: api, historyRepository: historyRepo)
            let viewModel = ProductSearchViewModel(lookupService: lookupService)

            // Act: Search with empty query
            viewModel.searchQuery = ""
            await viewModel.search()

            // Assert: Should not perform search
            #expect(viewModel.searchResults.isEmpty)
            #expect(!viewModel.isLoading)
        }
    }

    // MARK: - Scan History Flow Tests

    @Suite("Complete Scan History Flow")
    struct ScanHistoryFlowTests {

        @Test("Complete history flow: scan → save → retrieve → display")
        @MainActor
        func testCompleteHistoryFlow() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self, Supplement.self, UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let historyRepo = ScanHistoryRepository(modelContext: context)

            // Act: Save multiple scan entries
            let history1 = ScanHistory(
                barcode: "1111111111111",
                productName: "Product 1",
                brand: "Brand A",
                imageUrl: nil,
                wasSuccessful: true
            )
            // Manually set scannedAt to test ordering
            history1.scannedAt = Date().addingTimeInterval(-3600) // 1 hour ago

            let history2 = ScanHistory(
                barcode: "2222222222222",
                productName: "Product 2",
                brand: "Brand B",
                imageUrl: nil,
                wasSuccessful: true
            )
            history2.scannedAt = Date().addingTimeInterval(-1800) // 30 min ago

            let history3 = ScanHistory(
                barcode: "3333333333333",
                productName: "Product 3",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: false
            )

            try await historyRepo.save(history1)
            try await historyRepo.save(history2)
            try await historyRepo.save(history3)

            // Create ViewModel and load history
            let mockSession = MockURLSession()
            let api = OpenFoodFactsAPI(session: mockSession)
            let lookupService = ProductLookupService(api: api, historyRepository: historyRepo)
            let viewModel = ScanHistoryViewModel(lookupService: lookupService)

            await viewModel.loadHistory()

            // Assert: History should be loaded in reverse chronological order
            #expect(viewModel.scanHistory.count == 3)
            #expect(viewModel.scanHistory[0].productName == "Product 3")  // Most recent
            #expect(viewModel.scanHistory[1].productName == "Product 2")
            #expect(viewModel.scanHistory[2].productName == "Product 1")  // Oldest
        }

        @Test("History flow: delete single entry")
        @MainActor
        func testDeleteHistoryEntry() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self, Supplement.self, UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let historyRepo = ScanHistoryRepository(modelContext: context)

            let history1 = ScanHistory(
                barcode: "1111111111111",
                productName: "Product 1",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: true
            )
            let history2 = ScanHistory(
                barcode: "2222222222222",
                productName: "Product 2",
                brand: nil,
                imageUrl: nil,
                wasSuccessful: true
            )

            try await historyRepo.save(history1)
            try await historyRepo.save(history2)

            let mockSession = MockURLSession()
            let api = OpenFoodFactsAPI(session: mockSession)
            let lookupService = ProductLookupService(api: api, historyRepository: historyRepo)
            let viewModel = ScanHistoryViewModel(lookupService: lookupService)

            await viewModel.loadHistory()
            #expect(viewModel.scanHistory.count == 2)

            // Act: Delete one entry
            await viewModel.deleteHistory(history1)

            // Assert: Only one should remain
            #expect(viewModel.scanHistory.count == 1)
            #expect(viewModel.scanHistory[0].productName == "Product 2")
        }

        @Test("History flow: clear all history")
        @MainActor
        func testClearAllHistory() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self, Supplement.self, UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let historyRepo = ScanHistoryRepository(modelContext: context)

            // Add multiple entries
            for i in 1...5 {
                let history = ScanHistory(
                    barcode: "\(i)\(i)\(i)\(i)\(i)\(i)\(i)\(i)\(i)\(i)\(i)\(i)\(i)",
                    productName: "Product \(i)",
                    brand: nil,
                    imageUrl: nil,
                    wasSuccessful: true
                )
                try await historyRepo.save(history)
            }

            let mockSession = MockURLSession()
            let api = OpenFoodFactsAPI(session: mockSession)
            let lookupService = ProductLookupService(api: api, historyRepository: historyRepo)
            let viewModel = ScanHistoryViewModel(lookupService: lookupService)

            await viewModel.loadHistory()
            #expect(viewModel.scanHistory.count == 5)

            // Act: Clear all history
            await viewModel.clearAllHistory()

            // Assert: History should be empty
            #expect(viewModel.scanHistory.isEmpty)
        }
    }

    // MARK: - Product Addition Flow Tests

    @Suite("Complete Product Addition Flow")
    struct ProductAdditionFlowTests {

        @Test("Complete flow: scan → convert → save as supplement")
        @MainActor
        func testScanToSupplementFlow() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self, Supplement.self, UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let testProduct = ScannedProduct(
                barcode: "4006381333931",
                name: "Vitamin D3 20μg",
                brand: "Test Brand",
                imageUrl: nil,
                servingSize: "1 tablet",
                nutrients: [
                    ScannedNutrient(name: "Vitamin D", amount: 20.0, unit: "μg"),
                    ScannedNutrient(name: "Vitamin C", amount: 100.0, unit: "mg")
                ]
            )
            let productData = try JSONEncoder().encode(testProduct)

            let mockSession = MockURLSession()
            mockSession.mockData = productData
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://world.openfoodfacts.org/api/v2/product/4006381333931")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )

            let api = OpenFoodFactsAPI(session: mockSession)
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let lookupService = ProductLookupService(api: api, historyRepository: historyRepo)

            // Act: Lookup and convert to supplement
            let product = try await lookupService.lookupByBarcode("4006381333931")
            #expect(product != nil)

            let supplement = try await lookupService.saveAsLocalSupplement(product!, servingsPerDay: 1)

            // Assert: Supplement should be created with correct nutrients
            #expect(supplement.name == "Vitamin D3 20μg")
            #expect(supplement.brand == "Test Brand")
            #expect(supplement.servingsPerDay == 1)
            #expect(supplement.nutrients.count == 2)

            // Verify nutrients were mapped correctly
            let vitaminD = supplement.nutrients.first { $0.type == NutrientType.vitaminD }
            let vitaminC = supplement.nutrients.first { $0.type == NutrientType.vitaminC }

            #expect(vitaminD != nil)
            #expect(vitaminD?.amount == 20.0)
            #expect(vitaminC != nil)
            #expect(vitaminC?.amount == 100.0)
        }

        @Test("Nutrient mapping handles unknown nutrients gracefully")
        @MainActor
        func testNutrientMappingWithUnknownNutrients() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self, Supplement.self, UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let testProduct = ScannedProduct(
                barcode: "1234567890123",
                name: "Multi Vitamin",
                brand: nil,
                imageUrl: nil,
                servingSize: "1 tablet",
                nutrients: [
                    ScannedNutrient(name: "Vitamin D", amount: 20.0, unit: "μg"),
                    ScannedNutrient(name: "Unknown Nutrient", amount: 50.0, unit: "mg"),  // Unknown
                    ScannedNutrient(name: "Vitamin C", amount: 100.0, unit: "mg")
                ]
            )
            let productData = try JSONEncoder().encode(testProduct)

            let mockSession = MockURLSession()
            mockSession.mockData = productData
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://world.openfoodfacts.org/api/v2/product/1234567890123")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )

            let api = OpenFoodFactsAPI(session: mockSession)
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let lookupService = ProductLookupService(api: api, historyRepository: historyRepo)

            // Act
            let product = try await lookupService.lookupByBarcode("1234567890123")
            let supplement = try await lookupService.saveAsLocalSupplement(product!, servingsPerDay: 1)

            // Assert: Should only include mapped nutrients
            #expect(supplement.nutrients.count == 2)  // Only Vitamin D and C
            #expect(supplement.nutrients.contains { $0.type == NutrientType.vitaminD })
            #expect(supplement.nutrients.contains { $0.type == NutrientType.vitaminC })
        }
    }

    // MARK: - Error Handling Tests

    @Suite("Error Handling in Complete Flows")
    struct ErrorHandlingTests {

        @Test("Handle API rate limiting gracefully")
        @MainActor
        func testRateLimitingError() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self, Supplement.self, UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let mockSession = MockURLSession()
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://world.openfoodfacts.org/api/v2/product/4006381333931")!,
                statusCode: 429,  // Rate limited
                httpVersion: nil,
                headerFields: nil
            )

            let api = OpenFoodFactsAPI(session: mockSession)
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let lookupService = ProductLookupService(api: api, historyRepository: historyRepo)
            let viewModel = BarcodeScannerViewModel(scannerService: BarcodeScannerService(), lookupService: lookupService)

            // Act
            await viewModel.handleScannedBarcode("4006381333931")

            // Assert: Should show appropriate error
            if case .error(let message) = viewModel.scanState {
                #expect(message.contains("rate") || message.contains("limit") || message.contains("many") || message.contains("try") || message.contains("later"))
            } else {
                Issue.record("Expected error state for rate limiting")
            }
        }

        @Test("Handle invalid response from API")
        @MainActor
        func testInvalidResponseError() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ScanHistory.self, Supplement.self, UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let mockSession = MockURLSession()
            mockSession.mockData = Data("invalid json".utf8)
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://world.openfoodfacts.org/api/v2/search")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )

            let api = OpenFoodFactsAPI(session: mockSession)
            let historyRepo = ScanHistoryRepository(modelContext: context)
            let lookupService = ProductLookupService(api: api, historyRepository: historyRepo)
            let viewModel = ProductSearchViewModel(lookupService: lookupService)

            // Act
            viewModel.searchQuery = "test"
            await viewModel.search()

            // Assert: Should show error message
            #expect(viewModel.errorMessage != nil)
            #expect(viewModel.searchResults.isEmpty)
        }
    }
}
