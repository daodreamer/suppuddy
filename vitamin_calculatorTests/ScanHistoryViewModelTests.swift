import Testing
import SwiftData
import Foundation
@testable import vitamin_calculator

// MARK: - Mock Service

/// Mock ProductLookupService for history testing
@MainActor
final class MockScanHistoryLookupService: ProductLookupServiceProtocol {
    var mockScanHistory: [ScanHistory] = []
    var shouldThrowError: Error?
    var deleteCallCount = 0
    var clearCallCount = 0
    var getRecentScansCallCount = 0

    func lookupByBarcode(_ barcode: String) async throws -> ScannedProduct? {
        return nil
    }

    func saveScanHistory(barcode: String, product: ScannedProduct?, wasSuccessful: Bool) async throws {
        // Mock implementation
    }

    func searchProducts(query: String, page: Int) async throws -> ProductSearchResult {
        return ProductSearchResult(products: [], totalCount: 0, page: page, pageSize: 20)
    }

    func getRecentScans() async throws -> [ScanHistory] {
        getRecentScansCallCount += 1
        if let error = shouldThrowError {
            throw error
        }
        return mockScanHistory
    }

    func deleteHistory(_ item: ScanHistory) async throws {
        deleteCallCount += 1
        if let error = shouldThrowError {
            throw error
        }
        // Remove from mock data
        mockScanHistory.removeAll { $0.barcode == item.barcode }
    }

    func clearHistory() async throws {
        clearCallCount += 1
        if let error = shouldThrowError {
            throw error
        }
        mockScanHistory.removeAll()
    }
}

/// ScanHistoryViewModel 测试套件
@Suite("ScanHistoryViewModel Tests")
@MainActor
struct ScanHistoryViewModelTests {

    // MARK: - Test Helpers

    /// 创建测试用的 ScanHistory
    private static func makeScanHistory(barcode: String, productName: String) -> ScanHistory {
        return ScanHistory(
            barcode: barcode,
            productName: productName,
            brand: "Test Brand",
            imageUrl: nil,
            wasSuccessful: true
        )
    }

    // MARK: - Initialization Tests

    @Suite("Initialization Tests")
    struct InitializationTests {

        @Test("Should initialize with empty state")
        @MainActor
        func testInitialState() {
            // Arrange
            let lookupService = MockScanHistoryLookupService()

            // Act
            let viewModel = ScanHistoryViewModel(lookupService: lookupService)

            // Assert
            #expect(viewModel.scanHistory.isEmpty)
            #expect(!viewModel.isLoading)
            #expect(viewModel.errorMessage == nil)
            #expect(viewModel.selectedHistory == nil)
        }
    }

    // MARK: - Load History Tests

    @Suite("Load History Tests")
    struct LoadHistoryTests {

        @Test("Should load scan history")
        @MainActor
        func testLoadHistory() async {
            // Arrange
            let lookupService = MockScanHistoryLookupService()
            lookupService.mockScanHistory = [
                makeScanHistory(barcode: "123", productName: "Product 1"),
                makeScanHistory(barcode: "456", productName: "Product 2")
            ]

            let viewModel = ScanHistoryViewModel(lookupService: lookupService)

            // Act
            await viewModel.loadHistory()

            // Assert
            #expect(viewModel.scanHistory.count == 2)
            #expect(viewModel.scanHistory[0].productName == "Product 1")
            #expect(viewModel.scanHistory[1].productName == "Product 2")
            #expect(lookupService.getRecentScansCallCount == 1)
        }

        @Test("Should handle empty history")
        @MainActor
        func testLoadEmptyHistory() async {
            // Arrange
            let lookupService = MockScanHistoryLookupService()
            lookupService.mockScanHistory = []

            let viewModel = ScanHistoryViewModel(lookupService: lookupService)

            // Act
            await viewModel.loadHistory()

            // Assert
            #expect(viewModel.scanHistory.isEmpty)
            #expect(viewModel.errorMessage == nil)
        }

        @Test("Should handle load error")
        @MainActor
        func testLoadHistoryError() async {
            // Arrange
            let lookupService = MockScanHistoryLookupService()
            lookupService.shouldThrowError = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Load failed"])

            let viewModel = ScanHistoryViewModel(lookupService: lookupService)

            // Act
            await viewModel.loadHistory()

            // Assert
            #expect(viewModel.scanHistory.isEmpty)
            #expect(viewModel.errorMessage != nil)
        }
    }

    // MARK: - Delete History Tests

    @Suite("Delete History Tests")
    struct DeleteHistoryTests {

        @Test("Should delete single history item")
        @MainActor
        func testDeleteHistory() async {
            // Arrange
            let lookupService = MockScanHistoryLookupService()
            let history1 = makeScanHistory(barcode: "123", productName: "Product 1")
            let history2 = makeScanHistory(barcode: "456", productName: "Product 2")
            lookupService.mockScanHistory = [history1, history2]

            let viewModel = ScanHistoryViewModel(lookupService: lookupService)
            await viewModel.loadHistory()

            // Act
            await viewModel.deleteHistory(history1)

            // Assert
            #expect(lookupService.deleteCallCount == 1)
            // After deletion and reload, should have 1 item
            #expect(viewModel.scanHistory.count == 1)
            #expect(viewModel.scanHistory[0].productName == "Product 2")
        }

        @Test("Should handle delete error")
        @MainActor
        func testDeleteHistoryError() async {
            // Arrange
            let lookupService = MockScanHistoryLookupService()
            let history = makeScanHistory(barcode: "123", productName: "Product 1")
            lookupService.mockScanHistory = [history]

            let viewModel = ScanHistoryViewModel(lookupService: lookupService)
            await viewModel.loadHistory()

            // Set error after loading
            lookupService.shouldThrowError = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Delete failed"])

            // Act
            await viewModel.deleteHistory(history)

            // Assert
            #expect(viewModel.errorMessage != nil)
        }
    }

    // MARK: - Clear All Tests

    @Suite("Clear All History Tests")
    struct ClearAllTests {

        @Test("Should clear all history")
        @MainActor
        func testClearAllHistory() async {
            // Arrange
            let lookupService = MockScanHistoryLookupService()
            lookupService.mockScanHistory = [
                makeScanHistory(barcode: "123", productName: "Product 1"),
                makeScanHistory(barcode: "456", productName: "Product 2"),
                makeScanHistory(barcode: "789", productName: "Product 3")
            ]

            let viewModel = ScanHistoryViewModel(lookupService: lookupService)
            await viewModel.loadHistory()
            #expect(viewModel.scanHistory.count == 3)

            // Act
            await viewModel.clearAllHistory()

            // Assert
            #expect(lookupService.clearCallCount == 1)
            #expect(viewModel.scanHistory.isEmpty)
        }

        @Test("Should handle clear all error")
        @MainActor
        func testClearAllHistoryError() async {
            // Arrange
            let lookupService = MockScanHistoryLookupService()
            lookupService.mockScanHistory = [
                makeScanHistory(barcode: "123", productName: "Product 1")
            ]

            let viewModel = ScanHistoryViewModel(lookupService: lookupService)
            await viewModel.loadHistory()

            // Set error after loading
            lookupService.shouldThrowError = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Clear failed"])

            // Act
            await viewModel.clearAllHistory()

            // Assert
            #expect(viewModel.errorMessage != nil)
        }
    }

    // MARK: - Selection Tests

    @Suite("Selection Tests")
    struct SelectionTests {

        @Test("Should select history item")
        @MainActor
        func testSelectHistory() async {
            // Arrange
            let lookupService = MockScanHistoryLookupService()
            let history = makeScanHistory(barcode: "123", productName: "Product 1")
            lookupService.mockScanHistory = [history]

            let viewModel = ScanHistoryViewModel(lookupService: lookupService)
            await viewModel.loadHistory()

            // Act
            viewModel.selectHistory(history)

            // Assert
            #expect(viewModel.selectedHistory != nil)
            #expect(viewModel.selectedHistory?.barcode == "123")
        }

        @Test("Should clear selection")
        @MainActor
        func testClearSelection() async {
            // Arrange
            let lookupService = MockScanHistoryLookupService()
            let history = makeScanHistory(barcode: "123", productName: "Product 1")
            lookupService.mockScanHistory = [history]

            let viewModel = ScanHistoryViewModel(lookupService: lookupService)
            await viewModel.loadHistory()
            viewModel.selectHistory(history)

            // Act
            viewModel.clearSelection()

            // Assert
            #expect(viewModel.selectedHistory == nil)
        }
    }

    // MARK: - Loading State Tests

    @Suite("Loading State Tests")
    struct LoadingStateTests {

        @Test("Should show loading state during load")
        @MainActor
        func testLoadingStateDuringLoad() async {
            // Arrange
            let lookupService = MockScanHistoryLookupService()
            lookupService.mockScanHistory = [
                makeScanHistory(barcode: "123", productName: "Product 1")
            ]

            let viewModel = ScanHistoryViewModel(lookupService: lookupService)

            // Act
            await viewModel.loadHistory()

            // Assert
            // After completion, isLoading should be false
            #expect(!viewModel.isLoading)
        }
    }

    // MARK: - Error Handling Tests

    @Suite("Error Handling Tests")
    struct ErrorHandlingTests {

        @Test("Should clear error on successful operation")
        @MainActor
        func testClearErrorOnSuccess() async {
            // Arrange
            let lookupService = MockScanHistoryLookupService()

            // First, cause an error
            lookupService.shouldThrowError = NSError(domain: "test", code: -1)
            let viewModel = ScanHistoryViewModel(lookupService: lookupService)
            await viewModel.loadHistory()
            #expect(viewModel.errorMessage != nil)

            // Fix the error
            lookupService.shouldThrowError = nil
            lookupService.mockScanHistory = [
                makeScanHistory(barcode: "123", productName: "Product 1")
            ]

            // Act
            await viewModel.loadHistory()

            // Assert
            #expect(viewModel.errorMessage == nil)
            #expect(viewModel.scanHistory.count == 1)
        }
    }
}
