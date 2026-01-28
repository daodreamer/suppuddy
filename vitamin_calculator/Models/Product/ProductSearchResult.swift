//
//  ProductSearchResult.swift
//  vitamin_calculator
//
//  Created by TDD on 26.01.26.
//

import Foundation

/// Represents a paginated search result from a product database API.
/// Contains the list of products for the current page and pagination metadata.
struct ProductSearchResult: Codable, Sendable {
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
}
