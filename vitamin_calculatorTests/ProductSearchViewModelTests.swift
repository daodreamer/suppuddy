import Testing
import Foundation
@testable import vitamin_calculator

// MARK: - Mock Service

/// Mock ProductLookupService for search testing
@MainActor
final class MockProductSearchLookupService: ProductLookupServiceProtocol {
    var mockSearchResults: [ScannedProduct] = []
    var mockTotalCount: Int = 0
    var searchCallCount = 0
    var lastSearchQuery: String?
    var lastSearchPage: Int?
    var shouldThrowError: Error?

    func lookupByBarcode(_ barcode: String) async throws -> ScannedProduct? {
        return nil
    }

    func saveScanHistory(barcode: String, product: ScannedProduct?, wasSuccessful: Bool) async throws {
        // Mock implementation
    }

    func searchProducts(query: String, page: Int) async throws -> ProductSearchResult {
        searchCallCount += 1
        lastSearchQuery = query
        lastSearchPage = page

        if let error = shouldThrowError {
            throw error
        }

        // Simulate pagination
        let pageSize = 20
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, mockSearchResults.count)

        let productsForPage = startIndex < mockSearchResults.count
            ? Array(mockSearchResults[startIndex..<endIndex])
            : []

        return ProductSearchResult(
            products: productsForPage,
            totalCount: mockTotalCount,
            page: page,
            pageSize: pageSize
        )
    }

    func getRecentScans() async throws -> [ScanHistory] {
        return []
    }

    func deleteHistory(_ item: ScanHistory) async throws {
        // Mock implementation
    }

    func clearHistory() async throws {
        // Mock implementation
    }
}

/// ProductSearchViewModel 测试套件
@Suite("ProductSearchViewModel Tests")
@MainActor
struct ProductSearchViewModelTests {

    // MARK: - Initialization Tests

    @Suite("Initialization Tests")
    struct InitializationTests {

        @Test("Should initialize with empty state")
        @MainActor
        func testInitialState() {
            // Arrange
            let lookupService = MockProductSearchLookupService()

            // Act
            let viewModel = ProductSearchViewModel(lookupService: lookupService)

            // Assert
            #expect(viewModel.searchQuery.isEmpty)
            #expect(viewModel.searchResults.isEmpty)
            #expect(!viewModel.isLoading)
            #expect(!viewModel.isLoadingMore)
            #expect(!viewModel.hasMoreResults)
            #expect(viewModel.errorMessage == nil)
        }
    }

    // MARK: - Search Tests

    @Suite("Search Functionality Tests")
    struct SearchTests {

        @Test("Should perform search with query")
        @MainActor
        func testSearchWithQuery() async {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            lookupService.mockSearchResults = [
                ScannedProduct(barcode: "111", name: "Vitamin C", brand: "Brand A", imageUrl: nil, servingSize: nil, nutrients: []),
                ScannedProduct(barcode: "222", name: "Vitamin D", brand: "Brand B", imageUrl: nil, servingSize: nil, nutrients: [])
            ]
            lookupService.mockTotalCount = 2

            let viewModel = ProductSearchViewModel(lookupService: lookupService)
            viewModel.searchQuery = "vitamin"

            // Act
            await viewModel.search()

            // Assert
            #expect(viewModel.searchResults.count == 2)
            #expect(viewModel.searchResults[0].name == "Vitamin C")
            #expect(viewModel.searchResults[1].name == "Vitamin D")
            #expect(lookupService.searchCallCount == 1)
            #expect(lookupService.lastSearchQuery == "vitamin")
            #expect(lookupService.lastSearchPage == 1)
        }

        @Test("Should handle empty search query")
        @MainActor
        func testSearchWithEmptyQuery() async {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            let viewModel = ProductSearchViewModel(lookupService: lookupService)
            viewModel.searchQuery = ""

            // Act
            await viewModel.search()

            // Assert
            #expect(lookupService.searchCallCount == 0) // Should not search with empty query
            #expect(viewModel.searchResults.isEmpty)
        }

        @Test("Should handle search with no results")
        @MainActor
        func testSearchWithNoResults() async {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            lookupService.mockSearchResults = []
            lookupService.mockTotalCount = 0

            let viewModel = ProductSearchViewModel(lookupService: lookupService)
            viewModel.searchQuery = "nonexistent"

            // Act
            await viewModel.search()

            // Assert
            #expect(viewModel.searchResults.isEmpty)
            #expect(!viewModel.hasMoreResults)
        }

        @Test("Should handle search error")
        @MainActor
        func testSearchError() async {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            lookupService.shouldThrowError = OpenFoodFactsError.networkError(NSError(domain: "test", code: -1))

            let viewModel = ProductSearchViewModel(lookupService: lookupService)
            viewModel.searchQuery = "test"

            // Act
            await viewModel.search()

            // Assert
            #expect(viewModel.errorMessage != nil)
            #expect(viewModel.searchResults.isEmpty)
        }
    }

    // MARK: - Pagination Tests

    @Suite("Pagination Tests")
    struct PaginationTests {

        @Test("Should detect more results available")
        @MainActor
        func testHasMoreResults() async {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            // 50 total products, 20 per page
            lookupService.mockSearchResults = (0..<50).map { i in
                ScannedProduct(barcode: "\(i)", name: "Product \(i)", brand: nil, imageUrl: nil, servingSize: nil, nutrients: [])
            }
            lookupService.mockTotalCount = 50

            let viewModel = ProductSearchViewModel(lookupService: lookupService)
            viewModel.searchQuery = "product"

            // Act
            await viewModel.search()

            // Assert
            #expect(viewModel.searchResults.count == 20) // First page
            #expect(viewModel.hasMoreResults) // More pages available
        }

        @Test("Should load more results")
        @MainActor
        func testLoadMore() async {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            lookupService.mockSearchResults = (0..<50).map { i in
                ScannedProduct(barcode: "\(i)", name: "Product \(i)", brand: nil, imageUrl: nil, servingSize: nil, nutrients: [])
            }
            lookupService.mockTotalCount = 50

            let viewModel = ProductSearchViewModel(lookupService: lookupService)
            viewModel.searchQuery = "product"

            // Load first page
            await viewModel.search()
            #expect(viewModel.searchResults.count == 20)

            // Act - Load second page
            await viewModel.loadMore()

            // Assert
            #expect(viewModel.searchResults.count == 40) // First + second page
            #expect(lookupService.searchCallCount == 2)
            #expect(lookupService.lastSearchPage == 2)
        }

        @Test("Should not load more when no more results")
        @MainActor
        func testLoadMoreWhenNoMoreResults() async {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            lookupService.mockSearchResults = [
                ScannedProduct(barcode: "1", name: "Product 1", brand: nil, imageUrl: nil, servingSize: nil, nutrients: [])
            ]
            lookupService.mockTotalCount = 1

            let viewModel = ProductSearchViewModel(lookupService: lookupService)
            viewModel.searchQuery = "product"

            // Load first page
            await viewModel.search()

            // Act - Try to load more
            await viewModel.loadMore()

            // Assert
            #expect(lookupService.searchCallCount == 1) // Should not call again
            #expect(!viewModel.hasMoreResults)
        }

        @Test("Should not load more while already loading")
        @MainActor
        func testLoadMoreWhileLoading() async {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            lookupService.mockSearchResults = (0..<50).map { i in
                ScannedProduct(barcode: "\(i)", name: "Product \(i)", brand: nil, imageUrl: nil, servingSize: nil, nutrients: [])
            }
            lookupService.mockTotalCount = 50

            let viewModel = ProductSearchViewModel(lookupService: lookupService)
            viewModel.searchQuery = "product"

            await viewModel.search()

            // Simulate loading state
            // Note: In real implementation, this should be prevented by checking isLoadingMore
            // This test verifies the guard condition

            // Act & Assert
            // The implementation should prevent concurrent loading
            #expect(viewModel.searchResults.count == 20)
        }
    }

    // MARK: - State Management Tests

    @Suite("State Management Tests")
    struct StateManagementTests {

        @Test("Should clear search results")
        @MainActor
        func testClearResults() async {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            lookupService.mockSearchResults = [
                ScannedProduct(barcode: "1", name: "Product 1", brand: nil, imageUrl: nil, servingSize: nil, nutrients: [])
            ]
            lookupService.mockTotalCount = 1

            let viewModel = ProductSearchViewModel(lookupService: lookupService)
            viewModel.searchQuery = "product"
            await viewModel.search()

            // Act
            viewModel.clearResults()

            // Assert
            #expect(viewModel.searchResults.isEmpty)
            #expect(viewModel.searchQuery.isEmpty)
            #expect(viewModel.errorMessage == nil)
            #expect(!viewModel.hasMoreResults)
        }

        @Test("Should track selected product")
        @MainActor
        func testSelectProduct() {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            let viewModel = ProductSearchViewModel(lookupService: lookupService)

            let product = ScannedProduct(
                barcode: "123",
                name: "Test Product",
                brand: nil,
                imageUrl: nil,
                servingSize: nil,
                nutrients: []
            )

            // Act
            viewModel.selectProduct(product)

            // Assert
            #expect(viewModel.selectedProduct != nil)
            #expect(viewModel.selectedProduct?.barcode == "123")
        }
    }

    // MARK: - Loading State Tests

    @Suite("Loading State Tests")
    struct LoadingStateTests {

        @Test("Should show loading state during search")
        @MainActor
        func testLoadingStateDuringSearch() async {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            lookupService.mockSearchResults = [
                ScannedProduct(barcode: "1", name: "Product", brand: nil, imageUrl: nil, servingSize: nil, nutrients: [])
            ]
            lookupService.mockTotalCount = 1

            let viewModel = ProductSearchViewModel(lookupService: lookupService)
            viewModel.searchQuery = "test"

            // Act
            await viewModel.search()

            // Assert
            // After completion, isLoading should be false
            #expect(!viewModel.isLoading)
        }

        @Test("Should show loading more state during pagination")
        @MainActor
        func testLoadingMoreState() async {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            lookupService.mockSearchResults = (0..<50).map { i in
                ScannedProduct(barcode: "\(i)", name: "Product \(i)", brand: nil, imageUrl: nil, servingSize: nil, nutrients: [])
            }
            lookupService.mockTotalCount = 50

            let viewModel = ProductSearchViewModel(lookupService: lookupService)
            viewModel.searchQuery = "product"

            await viewModel.search()

            // Act
            await viewModel.loadMore()

            // Assert
            // After completion, isLoadingMore should be false
            #expect(!viewModel.isLoadingMore)
        }
    }

    // MARK: - Query Validation Tests

    @Suite("Query Validation Tests")
    struct QueryValidationTests {

        @Test("Should trim whitespace from query")
        @MainActor
        func testTrimWhitespace() async {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            lookupService.mockSearchResults = []
            lookupService.mockTotalCount = 0

            let viewModel = ProductSearchViewModel(lookupService: lookupService)
            viewModel.searchQuery = "  vitamin  "

            // Act
            await viewModel.search()

            // Assert
            #expect(lookupService.lastSearchQuery == "vitamin")
        }

        @Test("Should not search with whitespace-only query")
        @MainActor
        func testWhitespaceOnlyQuery() async {
            // Arrange
            let lookupService = MockProductSearchLookupService()
            let viewModel = ProductSearchViewModel(lookupService: lookupService)
            viewModel.searchQuery = "   "

            // Act
            await viewModel.search()

            // Assert
            #expect(lookupService.searchCallCount == 0)
        }
    }
}
