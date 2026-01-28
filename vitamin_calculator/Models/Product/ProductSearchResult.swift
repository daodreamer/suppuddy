//
//  ProductSearchResult.swift
//  vitamin_calculator
//
//  Created by TDD on 26.01.26.
//

import Foundation

/// Represents a paginated search result from a product database API.
/// Contains the list of products for the current page and pagination metadata.
struct ProductSearchResult: Sendable {
    // MARK: - Properties

    /// The list of products in the current page
    let products: [ScannedProduct]

    /// Total number of products matching the search query
    let totalCount: Int

    /// Current page number (1-indexed)
    let page: Int

    /// Number of products per page
    let pageSize: Int

    // MARK: - Computed Properties

    /// Indicates whether there are more pages available to fetch
    var hasMorePages: Bool {
        return page * pageSize < totalCount
    }

    // MARK: - Initialization

    /// Creates a new product search result
    /// - Parameters:
    ///   - products: The list of products in the current page
    ///   - totalCount: Total number of products matching the search query
    ///   - page: Current page number (1-indexed)
    ///   - pageSize: Number of products per page
    init(
        products: [ScannedProduct],
        totalCount: Int,
        page: Int,
        pageSize: Int
    ) {
        self.products = products
        self.totalCount = totalCount
        self.page = page
        self.pageSize = pageSize
    }

    // MARK: - Codable Conformance

    enum CodingKeys: String, CodingKey {
        case products
        case totalCount
        case page
        case pageSize
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.products = try container.decode([ScannedProduct].self, forKey: .products)
        self.totalCount = try container.decode(Int.self, forKey: .totalCount)
        self.page = try container.decode(Int.self, forKey: .page)
        self.pageSize = try container.decode(Int.self, forKey: .pageSize)
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(products, forKey: .products)
        try container.encode(totalCount, forKey: .totalCount)
        try container.encode(page, forKey: .page)
        try container.encode(pageSize, forKey: .pageSize)
    }
}
// MARK: - Codable Conformance
extension ProductSearchResult: Codable {}


