import Foundation
import Observation

/// ViewModel for the product search view.
/// Manages product search, pagination, and result display.
@MainActor
@Observable
final class ProductSearchViewModel {

    // MARK: - Properties

    /// Current search query
    var searchQuery: String = ""

    /// Search results
    var searchResults: [ScannedProduct] = []

    /// Whether initial search is loading
    var isLoading: Bool = false

    /// Whether loading more results (pagination)
    var isLoadingMore: Bool = false

    /// Whether more results are available
    var hasMoreResults: Bool = false

    /// Error message to display
    var errorMessage: String?

    /// Currently selected product
    var selectedProduct: ScannedProduct?

    /// Current page number (for pagination)
    private var currentPage: Int = 1

    /// Total count of results from last search
    private var totalCount: Int = 0

    /// Page size for pagination
    private let pageSize: Int = 20

    /// Product lookup service
    private let lookupService: any ProductLookupServiceProtocol

    /// Task for debouncing search
    private var searchTask: Task<Void, Never>?

    /// Debounce delay in seconds
    private let debounceDelay: TimeInterval = 0.5

    // MARK: - Initialization

    /// Creates a new ProductSearchViewModel
    /// - Parameter lookupService: Service for product lookup
    init(lookupService: any ProductLookupServiceProtocol) {
        self.lookupService = lookupService
    }

    /// Convenience initializer with concrete type
    /// - Parameter lookupService: Product lookup service
    init(lookupService: ProductLookupService) {
        self.lookupService = lookupService
    }

    // MARK: - Search

    /// Performs a debounced search with the current query
    /// Uses a 0.5 second delay to avoid excessive API calls while typing
    func search() async {
        // Trim and validate query
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        // Don't search with empty query
        guard !trimmedQuery.isEmpty else {
            searchResults = []
            hasMoreResults = false
            return
        }

        // Cancel any pending search
        searchTask?.cancel()

        // Create new search task with debouncing
        searchTask = Task {
            // Debounce delay
            try? await Task.sleep(for: .seconds(debounceDelay))

            // Check if cancelled during sleep
            guard !Task.isCancelled else { return }

            // Reset state
            currentPage = 1
            searchResults = []
            hasMoreResults = false
            errorMessage = nil
            isLoading = true

            do {
                let result = try await lookupService.searchProducts(
                    query: trimmedQuery,
                    page: currentPage
                )

                // Check if cancelled during request
                guard !Task.isCancelled else { return }

                // Update results
                searchResults = result.products
                totalCount = result.totalCount
                hasMoreResults = result.hasMorePages

            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
                searchResults = []
            }

            isLoading = false
        }

        // Await the task
        await searchTask?.value
    }

    /// Loads more results (next page)
    func loadMore() async {
        // Don't load if already loading or no more results
        guard !isLoadingMore && hasMoreResults else {
            return
        }

        isLoadingMore = true
        errorMessage = nil

        // Move to next page
        let nextPage = currentPage + 1

        do {
            let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            let result = try await lookupService.searchProducts(
                query: trimmedQuery,
                page: nextPage
            )

            // Append results
            searchResults.append(contentsOf: result.products)
            currentPage = nextPage
            hasMoreResults = result.hasMorePages

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMore = false
    }

    // MARK: - State Management

    /// Clears search results and query
    func clearResults() {
        searchResults = []
        searchQuery = ""
        errorMessage = nil
        hasMoreResults = false
        currentPage = 1
        totalCount = 0
        selectedProduct = nil
        searchTask?.cancel()
    }

    /// Selects a product from search results
    /// - Parameter product: The product to select
    func selectProduct(_ product: ScannedProduct) {
        selectedProduct = product
    }

    // MARK: - Debouncing

    /// Performs a debounced search
    /// - Parameter delay: Delay in nanoseconds (default: 500ms)
    func debouncedSearch(delay: UInt64 = 500_000_000) {
        // Cancel previous task
        searchTask?.cancel()

        // Create new task
        searchTask = Task {
            // Wait for delay
            try? await Task.sleep(nanoseconds: delay)

            // Check if cancelled
            guard !Task.isCancelled else { return }

            // Perform search
            await search()
        }
    }

    /// Cancels any pending debounced search
    func cancelDebouncedSearch() {
        searchTask?.cancel()
    }
}
