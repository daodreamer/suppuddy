import Foundation
import SwiftData

/// Protocol for OpenFoodFactsAPI to enable testing
protocol ProductAPIProtocol: Actor {
    func getProduct(barcode: String) async throws -> ScannedProduct?
    func searchProducts(query: String, page: Int, pageSize: Int) async throws -> ProductSearchResult
}

/// Make OpenFoodFactsAPI conform to the protocol
extension OpenFoodFactsAPI: ProductAPIProtocol {}

/// Service for looking up products from external APIs and managing scan history.
/// Integrates OpenFoodFactsAPI with local caching via ScanHistoryRepository.
@MainActor
final class ProductLookupService {

    // MARK: - Properties

    private let api: any ProductAPIProtocol
    private let historyRepository: ScanHistoryRepository
    private let supplementRepository: SupplementRepository?

    // MARK: - Initialization

    /// Creates a new product lookup service
    /// - Parameters:
    ///   - api: The API client for product lookups
    ///   - historyRepository: Repository for managing scan history
    ///   - supplementRepository: Optional repository for saving supplements
    init(
        api: any ProductAPIProtocol,
        historyRepository: ScanHistoryRepository,
        supplementRepository: SupplementRepository? = nil
    ) {
        self.api = api
        self.historyRepository = historyRepository
        self.supplementRepository = supplementRepository
    }

    // MARK: - Product Lookup

    /// Looks up a product by barcode.
    /// First checks the local cache, then queries the API if not found.
    /// - Parameter barcode: The barcode to look up
    /// - Returns: The scanned product if found, nil otherwise
    /// - Throws: API errors or database errors
    func lookupByBarcode(_ barcode: String) async throws -> ScannedProduct? {
        // Step 1: Check cache first
        if let history = try await historyRepository.getByBarcode(barcode),
           history.wasSuccessful,
           let cachedProduct = history.cachedProduct {
            return cachedProduct
        }

        // Step 2: Query API if cache miss
        let product = try await api.getProduct(barcode: barcode)

        // Step 3: Save to history if found
        if let product = product {
            try await saveScanHistory(
                barcode: barcode,
                product: product,
                wasSuccessful: true
            )
        }

        return product
    }

    /// Searches for products matching the query
    /// - Parameters:
    ///   - query: Search query string
    ///   - page: Page number for pagination
    /// - Returns: Search results with products and pagination info
    /// - Throws: API errors
    func searchProducts(query: String, page: Int) async throws -> ProductSearchResult {
        let pageSize = 20 // Default page size
        return try await api.searchProducts(
            query: query,
            page: page,
            pageSize: pageSize
        )
    }

    // MARK: - Scan History Management

    /// Saves a scan attempt to the history
    /// - Parameters:
    ///   - barcode: The scanned barcode
    ///   - product: The product data if found (nil if not found)
    ///   - wasSuccessful: Whether the scan successfully retrieved product data
    /// - Throws: Database errors
    func saveScanHistory(
        barcode: String,
        product: ScannedProduct?,
        wasSuccessful: Bool
    ) async throws {
        let history = ScanHistory(
            barcode: barcode,
            productName: product?.name ?? "Unknown",
            brand: product?.brand,
            imageUrl: product?.imageUrl,
            wasSuccessful: wasSuccessful
        )

        // Cache the full product data if available
        history.cachedProduct = product

        try await historyRepository.save(history)
    }

    /// Retrieves recent scan history
    /// - Returns: Array of recent scan history records, sorted by date descending
    /// - Throws: Database errors
    func getRecentScans() async throws -> [ScanHistory] {
        return try await historyRepository.getRecent(limit: 20)
    }

    /// Deletes a single scan history record
    /// - Parameter item: The history item to delete
    /// - Throws: Database errors
    func deleteHistory(_ item: ScanHistory) async throws {
        try await historyRepository.delete(item)
    }

    /// Clears all scan history
    /// - Throws: Database errors
    func clearHistory() async throws {
        try await historyRepository.clearAll()
    }

    // MARK: - Supplement Conversion

    /// Converts a scanned product to a local Supplement and saves it
    /// - Parameters:
    ///   - product: The scanned product to convert
    ///   - servingsPerDay: Number of servings per day
    /// - Returns: The created Supplement
    /// - Throws: Database errors or validation errors
    func saveAsLocalSupplement(
        _ product: ScannedProduct,
        servingsPerDay: Int
    ) async throws -> Supplement {
        // Convert scanned nutrients to local nutrients
        let nutrients = product.toNutrients()

        // Create the supplement
        let supplement = Supplement(
            name: product.name,
            brand: product.brand,
            servingSize: product.servingSize ?? "1 serving",
            servingsPerDay: servingsPerDay,
            nutrients: nutrients,
            notes: product.servingSize.map { "Scanned from barcode \(product.barcode). Original serving size: \($0)" }
        )

        // Save to repository if available
        if let repo = supplementRepository {
            try await repo.save(supplement)
        }

        return supplement
    }
}
