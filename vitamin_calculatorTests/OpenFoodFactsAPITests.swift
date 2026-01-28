//
//  OpenFoodFactsAPITests.swift
//  vitamin_calculatorTests
//
//  Created by TDD on 26.01.26.
//

import Foundation
import Testing
@testable import vitamin_calculator

// MARK: - Mock URLSession

/// Mock URL Session for testing
final class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }

        let data = mockData ?? Data()
        let response = mockResponse ?? HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        return (data, response)
    }
}

// MARK: - Tests

@Suite("OpenFoodFactsAPI Tests")
struct OpenFoodFactsAPITests {

    @Suite("Product Lookup Tests")
    struct ProductLookupTests {

        @Test("Get product by barcode returns product when found")
        func testGetProductSuccess() async throws {
            // Arrange
            let mockSession = MockURLSession()
            let jsonData = """
            {
                "barcode": "123456",
                "name": "Test Product",
                "brand": "Test Brand",
                "imageUrl": null,
                "servingSize": "1 serving",
                "nutrients": [
                    {"name": "vitamin-c", "amount": 100.0, "unit": "mg"}
                ]
            }
            """.data(using: .utf8)!

            mockSession.mockData = jsonData
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://test.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            let api = OpenFoodFactsAPI(session: mockSession)

            // Act
            let product = try await api.getProduct(barcode: "123456")

            // Assert
            #expect(product != nil)
            #expect(product?.barcode == "123456")
            #expect(product?.name == "Test Product")
        }

        @Test("Get product returns nil when not found (404)")
        func testGetProductNotFound() async throws {
            // Arrange
            let mockSession = MockURLSession()
            mockSession.mockData = Data()
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://test.com")!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!

            let api = OpenFoodFactsAPI(session: mockSession)

            // Act
            let product = try await api.getProduct(barcode: "nonexistent")

            // Assert
            #expect(product == nil)
        }

        @Test("Get product throws network error on failure")
        func testGetProductNetworkError() async throws {
            // Arrange
            let mockSession = MockURLSession()
            mockSession.mockError = NSError(domain: "test", code: -1, userInfo: nil)

            let api = OpenFoodFactsAPI(session: mockSession)

            // Act & Assert
            await #expect(throws: OpenFoodFactsError.self) {
                _ = try await api.getProduct(barcode: "123")
            }
        }

        @Test("Get product throws invalid response error on bad JSON")
        func testGetProductInvalidResponse() async throws {
            // Arrange
            let mockSession = MockURLSession()
            mockSession.mockData = "invalid json".data(using: .utf8)!
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://test.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            let api = OpenFoodFactsAPI(session: mockSession)

            // Act & Assert
            await #expect(throws: OpenFoodFactsError.self) {
                _ = try await api.getProduct(barcode: "123")
            }
        }
    }

    @Suite("Product Search Tests")
    struct ProductSearchTests {

        @Test("Search products returns results")
        func testSearchProductsSuccess() async throws {
            // Arrange
            let mockSession = MockURLSession()
            let jsonData = """
            {
                "products": [
                    {
                        "barcode": "111",
                        "name": "Product 1",
                        "brand": null,
                        "imageUrl": null,
                        "servingSize": null,
                        "nutrients": []
                    }
                ],
                "totalCount": 50,
                "page": 1,
                "pageSize": 10
            }
            """.data(using: .utf8)!

            mockSession.mockData = jsonData
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://test.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            let api = OpenFoodFactsAPI(session: mockSession)

            // Act
            let result = try await api.searchProducts(query: "vitamin", page: 1, pageSize: 10)

            // Assert
            #expect(result.products.count == 1)
            #expect(result.totalCount == 50)
            #expect(result.page == 1)
        }

        @Test("Search products with empty results")
        func testSearchProductsEmpty() async throws {
            // Arrange
            let mockSession = MockURLSession()
            let jsonData = """
            {
                "products": [],
                "totalCount": 0,
                "page": 1,
                "pageSize": 10
            }
            """.data(using: .utf8)!

            mockSession.mockData = jsonData
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://test.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            let api = OpenFoodFactsAPI(session: mockSession)

            // Act
            let result = try await api.searchProducts(query: "nonexistent", page: 1, pageSize: 10)

            // Assert
            #expect(result.products.isEmpty)
            #expect(result.totalCount == 0)
        }

        @Test("Search products throws error on network failure")
        func testSearchProductsNetworkError() async throws {
            // Arrange
            let mockSession = MockURLSession()
            mockSession.mockError = NSError(domain: "network", code: -1009, userInfo: nil)

            let api = OpenFoodFactsAPI(session: mockSession)

            // Act & Assert
            await #expect(throws: OpenFoodFactsError.self) {
                _ = try await api.searchProducts(query: "test", page: 1, pageSize: 10)
            }
        }
    }

    @Suite("Error Handling Tests")
    struct ErrorHandlingTests {

        @Test("Server error (500) throws appropriate error")
        func testServerError() async throws {
            // Arrange
            let mockSession = MockURLSession()
            mockSession.mockData = Data()
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://test.com")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!

            let api = OpenFoodFactsAPI(session: mockSession)

            // Act & Assert
            await #expect(throws: OpenFoodFactsError.self) {
                _ = try await api.getProduct(barcode: "123")
            }
        }

        @Test("Rate limit (429) throws rate limited error")
        func testRateLimit() async throws {
            // Arrange
            let mockSession = MockURLSession()
            mockSession.mockData = Data()
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://test.com")!,
                statusCode: 429,
                httpVersion: nil,
                headerFields: nil
            )!

            let api = OpenFoodFactsAPI(session: mockSession)

            // Act & Assert
            await #expect(throws: OpenFoodFactsError.self) {
                _ = try await api.getProduct(barcode: "123")
            }
        }
    }

    @Suite("Availability Check Tests")
    struct AvailabilityTests {

        @Test("Check availability returns true when API is reachable")
        func testCheckAvailabilitySuccess() async {
            // Arrange
            let mockSession = MockURLSession()
            mockSession.mockData = Data()
            mockSession.mockResponse = HTTPURLResponse(
                url: URL(string: "https://test.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            let api = OpenFoodFactsAPI(session: mockSession)

            // Act
            let available = await api.checkAvailability()

            // Assert
            #expect(available == true)
        }

        @Test("Check availability returns false when API is unreachable")
        func testCheckAvailabilityFailure() async {
            // Arrange
            let mockSession = MockURLSession()
            mockSession.mockError = NSError(domain: "test", code: -1, userInfo: nil)

            let api = OpenFoodFactsAPI(session: mockSession)

            // Act
            let available = await api.checkAvailability()

            // Assert
            #expect(available == false)
        }
    }
}
