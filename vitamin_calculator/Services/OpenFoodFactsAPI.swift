//
//  OpenFoodFactsAPI.swift
//  vitamin_calculator
//
//  Created by TDD on 26.01.26.
//

import Foundation

/// Protocol to abstract URLSession for testing
protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol { }

/// Errors that can occur when interacting with the Open Food Facts API
enum OpenFoodFactsError: Error, LocalizedError {
    case productNotFound
    case networkError(Error)
    case invalidResponse
    case rateLimited
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return NSLocalizedString("Product not found in database", comment: "Product not found error")
        case .networkError(let error):
            return String(format: NSLocalizedString("Network error: %@", comment: "Network error"), error.localizedDescription)
        case .invalidResponse:
            return NSLocalizedString("Invalid response from server", comment: "Invalid response error")
        case .rateLimited:
            return NSLocalizedString("Too many requests. Please try again later.", comment: "Rate limit error")
        case .serverError(let code):
            return String(format: NSLocalizedString("Server error: %d", comment: "Server error"), code)
        }
    }
}

/// Open Food Facts API client
/// Provides access to product information via barcode lookup and search
actor OpenFoodFactsAPI {

    // MARK: - Properties

    private let baseURL = "https://world.openfoodfacts.org/api/v2"
    private let session: URLSessionProtocol

    // MARK: - Initialization

    /// Creates a new Open Food Facts API client
    /// - Parameter session: The URL session to use for network requests (default: URLSession.shared)
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    // MARK: - Product Lookup

    /// Retrieves product information by barcode
    /// - Parameter barcode: The product barcode (EAN, UPC, etc.)
    /// - Returns: ScannedProduct if found, nil if not found
    /// - Throws: OpenFoodFactsError if the request fails
    func getProduct(barcode: String) async throws -> ScannedProduct? {
        let urlString = "\(baseURL)/product/\(barcode)"
        guard let url = URL(string: urlString) else {
            throw OpenFoodFactsError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenFoodFactsError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200:
                // Product found, decode it
                do {
                    let product = try decodeProduct(from: data)
                    return product
                } catch {
                    throw OpenFoodFactsError.invalidResponse
                }

            case 404:
                // Product not found
                return nil

            case 429:
                throw OpenFoodFactsError.rateLimited

            case 500...599:
                throw OpenFoodFactsError.serverError(httpResponse.statusCode)

            default:
                throw OpenFoodFactsError.invalidResponse
            }

        } catch let error as OpenFoodFactsError {
            throw error
        } catch {
            throw OpenFoodFactsError.networkError(error)
        }
    }

    // MARK: - Product Search

    /// Searches for products by query string
    /// - Parameters:
    ///   - query: Search query string
    ///   - page: Page number (1-indexed)
    ///   - pageSize: Number of results per page
    /// - Returns: ProductSearchResult containing matching products and pagination info
    /// - Throws: OpenFoodFactsError if the request fails
    func searchProducts(
        query: String,
        page: Int,
        pageSize: Int
    ) async throws -> ProductSearchResult {
        var components = URLComponents(string: "\(baseURL)/search")!
        components.queryItems = [
            URLQueryItem(name: "search_terms", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: String(pageSize))
        ]

        guard let url = components.url else {
            throw OpenFoodFactsError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenFoodFactsError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200:
                // Success, decode search results
                do {
                    let searchResult = try decodeSearchResult(from: data)
                    return searchResult
                } catch {
                    throw OpenFoodFactsError.invalidResponse
                }

            case 429:
                throw OpenFoodFactsError.rateLimited

            case 500...599:
                throw OpenFoodFactsError.serverError(httpResponse.statusCode)

            default:
                throw OpenFoodFactsError.invalidResponse
            }

        } catch let error as OpenFoodFactsError {
            throw error
        } catch {
            throw OpenFoodFactsError.networkError(error)
        }
    }

    // MARK: - Helper Methods

    /// Decodes product data
    /// - Parameter data: The JSON data to decode
    /// - Returns: Decoded ScannedProduct
    /// - Throws: DecodingError if decoding fails
    private func decodeProduct(from data: Data) throws -> ScannedProduct {
        let decoder = JSONDecoder()
        return try decoder.decode(ScannedProduct.self, from: data)
    }

    /// Decodes search result data
    /// - Parameter data: The JSON data to decode
    /// - Returns: Decoded ProductSearchResult
    /// - Throws: DecodingError if decoding fails
    private func decodeSearchResult(from data: Data) throws -> ProductSearchResult {
        let decoder = JSONDecoder()
        return try decoder.decode(ProductSearchResult.self, from: data)
    }

    // MARK: - Availability Check

    /// Checks if the Open Food Facts API is available
    /// - Returns: true if the API is reachable, false otherwise
    func checkAvailability() async -> Bool {
        let urlString = "\(baseURL)/product/test"
        guard let url = URL(string: urlString) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5

        do {
            let (_, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            // Any response (including 404) means the API is reachable
            return httpResponse.statusCode < 500
        } catch {
            return false
        }
    }
}
