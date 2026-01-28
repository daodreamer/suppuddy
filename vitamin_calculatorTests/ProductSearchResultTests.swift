//
//  ProductSearchResultTests.swift
//  vitamin_calculatorTests
//
//  Created by TDD on 26.01.26.
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("ProductSearchResult Model Tests")
struct ProductSearchResultTests {

    @Suite("Initialization Tests")
    struct InitializationTests {
        @Test("ProductSearchResult initializes with all properties")
        func testInitialization() {
            // Arrange & Act
            let products = [
                ScannedProduct(
                    barcode: "111",
                    name: "Product 1",
                    brand: nil,
                    imageUrl: nil,
                    servingSize: nil,
                    nutrients: []
                ),
                ScannedProduct(
                    barcode: "222",
                    name: "Product 2",
                    brand: nil,
                    imageUrl: nil,
                    servingSize: nil,
                    nutrients: []
                )
            ]
            let searchResult = ProductSearchResult(
                products: products,
                totalCount: 50,
                page: 1,
                pageSize: 10
            )

            // Assert
            #expect(searchResult.products.count == 2)
            #expect(searchResult.totalCount == 50)
            #expect(searchResult.page == 1)
            #expect(searchResult.pageSize == 10)
        }

        @Test("ProductSearchResult initializes with empty products")
        func testInitializationEmptyProducts() {
            // Arrange & Act
            let searchResult = ProductSearchResult(
                products: [],
                totalCount: 0,
                page: 1,
                pageSize: 10
            )

            // Assert
            #expect(searchResult.products.isEmpty)
            #expect(searchResult.totalCount == 0)
        }
    }

    @Suite("Pagination Calculation Tests")
    struct PaginationTests {
        @Test("hasMorePages returns true when more pages exist")
        func testHasMorePagesTrue() {
            // Arrange
            let searchResult = ProductSearchResult(
                products: [],
                totalCount: 50,
                page: 1,
                pageSize: 10
            )

            // Act & Assert
            // Page 1, pageSize 10: 1 * 10 = 10 < 50
            #expect(searchResult.hasMorePages == true)
        }

        @Test("hasMorePages returns false when no more pages")
        func testHasMorePagesFalseLastPage() {
            // Arrange
            let searchResult = ProductSearchResult(
                products: [],
                totalCount: 50,
                page: 5,
                pageSize: 10
            )

            // Act & Assert
            // Page 5, pageSize 10: 5 * 10 = 50, no more pages
            #expect(searchResult.hasMorePages == false)
        }

        @Test("hasMorePages returns false when on exact last page")
        func testHasMorePagesFalseExactMatch() {
            // Arrange
            let searchResult = ProductSearchResult(
                products: [],
                totalCount: 100,
                page: 10,
                pageSize: 10
            )

            // Act & Assert
            // Page 10, pageSize 10: 10 * 10 = 100, no more pages
            #expect(searchResult.hasMorePages == false)
        }

        @Test("hasMorePages returns false when totalCount is zero")
        func testHasMorePagesZeroTotal() {
            // Arrange
            let searchResult = ProductSearchResult(
                products: [],
                totalCount: 0,
                page: 1,
                pageSize: 10
            )

            // Act & Assert
            #expect(searchResult.hasMorePages == false)
        }

        @Test("hasMorePages handles partial last page")
        func testHasMorePagesPartialLastPage() {
            // Arrange
            let searchResult = ProductSearchResult(
                products: [],
                totalCount: 25,
                page: 2,
                pageSize: 10
            )

            // Act & Assert
            // Page 2, pageSize 10: 2 * 10 = 20 < 25, has more
            #expect(searchResult.hasMorePages == true)
        }

        @Test("hasMorePages at boundary")
        func testHasMorePagesBoundary() {
            // Arrange
            let searchResult = ProductSearchResult(
                products: [],
                totalCount: 25,
                page: 3,
                pageSize: 10
            )

            // Act & Assert
            // Page 3, pageSize 10: 3 * 10 = 30 > 25, no more pages
            #expect(searchResult.hasMorePages == false)
        }
    }

    @Suite("Codable Tests")
    struct CodableTests {
        @Test("ProductSearchResult should be encodable")
        func testEncoding() throws {
            // Arrange
            let products = [
                ScannedProduct(
                    barcode: "123",
                    name: "Test Product",
                    brand: "Brand",
                    imageUrl: nil,
                    servingSize: nil,
                    nutrients: []
                )
            ]
            let searchResult = ProductSearchResult(
                products: products,
                totalCount: 10,
                page: 1,
                pageSize: 10
            )
            let encoder = JSONEncoder()

            // Act
            let data = try encoder.encode(searchResult)

            // Assert
            #expect(!data.isEmpty)
        }

        @Test("ProductSearchResult should be decodable")
        func testDecoding() throws {
            // Arrange
            let products = [
                ScannedProduct(
                    barcode: "456",
                    name: "Another Product",
                    brand: nil,
                    imageUrl: nil,
                    servingSize: nil,
                    nutrients: []
                )
            ]
            let original = ProductSearchResult(
                products: products,
                totalCount: 20,
                page: 2,
                pageSize: 5
            )
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(ProductSearchResult.self, from: data)

            // Assert
            #expect(decoded.products.count == original.products.count)
            #expect(decoded.totalCount == original.totalCount)
            #expect(decoded.page == original.page)
            #expect(decoded.pageSize == original.pageSize)
        }

        @Test("ProductSearchResult should round-trip encode and decode")
        func testRoundTrip() throws {
            // Arrange
            let products = [
                ScannedProduct(barcode: "111", name: "P1", brand: nil, imageUrl: nil, servingSize: nil, nutrients: []),
                ScannedProduct(barcode: "222", name: "P2", brand: nil, imageUrl: nil, servingSize: nil, nutrients: []),
                ScannedProduct(barcode: "333", name: "P3", brand: nil, imageUrl: nil, servingSize: nil, nutrients: [])
            ]
            let original = ProductSearchResult(
                products: products,
                totalCount: 100,
                page: 3,
                pageSize: 20
            )
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(ProductSearchResult.self, from: data)

            // Assert
            #expect(decoded.products.count == 3)
            #expect(decoded.totalCount == 100)
            #expect(decoded.page == 3)
            #expect(decoded.pageSize == 20)
        }
    }

    @Suite("JSON Parsing Tests")
    struct JSONParsingTests {
        @Test("ProductSearchResult parses from JSON structure")
        func testJSONParsing() throws {
            // Arrange
            let jsonString = """
            {
                "products": [
                    {
                        "barcode": "1234567890123",
                        "name": "Vitamin D3",
                        "brand": "HealthBrand",
                        "imageUrl": "https://example.com/image.jpg",
                        "servingSize": "1 capsule",
                        "nutrients": []
                    }
                ],
                "totalCount": 42,
                "page": 1,
                "pageSize": 10
            }
            """
            let jsonData = jsonString.data(using: .utf8)!
            let decoder = JSONDecoder()

            // Act
            let searchResult = try decoder.decode(ProductSearchResult.self, from: jsonData)

            // Assert
            #expect(searchResult.products.count == 1)
            #expect(searchResult.products.first?.name == "Vitamin D3")
            #expect(searchResult.totalCount == 42)
            #expect(searchResult.page == 1)
            #expect(searchResult.pageSize == 10)
        }

        @Test("ProductSearchResult parses empty products array")
        func testJSONParsingEmptyProducts() throws {
            // Arrange
            let jsonString = """
            {
                "products": [],
                "totalCount": 0,
                "page": 1,
                "pageSize": 10
            }
            """
            let jsonData = jsonString.data(using: .utf8)!
            let decoder = JSONDecoder()

            // Act
            let searchResult = try decoder.decode(ProductSearchResult.self, from: jsonData)

            // Assert
            #expect(searchResult.products.isEmpty)
            #expect(searchResult.totalCount == 0)
        }
    }

    @Suite("Edge Case Tests")
    struct EdgeCaseTests {
        @Test("ProductSearchResult handles large totalCount")
        func testLargeTotalCount() {
            // Arrange & Act
            let searchResult = ProductSearchResult(
                products: [],
                totalCount: 10000,
                page: 1,
                pageSize: 50
            )

            // Assert
            #expect(searchResult.totalCount == 10000)
            #expect(searchResult.hasMorePages == true)
        }

        @Test("ProductSearchResult handles page 1 correctly")
        func testFirstPage() {
            // Arrange & Act
            let searchResult = ProductSearchResult(
                products: [],
                totalCount: 100,
                page: 1,
                pageSize: 20
            )

            // Assert
            #expect(searchResult.page == 1)
            #expect(searchResult.hasMorePages == true)
        }

        @Test("ProductSearchResult handles different page sizes")
        func testDifferentPageSizes() {
            // Arrange & Act
            let result1 = ProductSearchResult(products: [], totalCount: 100, page: 1, pageSize: 10)
            let result2 = ProductSearchResult(products: [], totalCount: 100, page: 1, pageSize: 25)
            let result3 = ProductSearchResult(products: [], totalCount: 100, page: 1, pageSize: 50)

            // Assert
            #expect(result1.hasMorePages == true)  // 10 < 100
            #expect(result2.hasMorePages == true)  // 25 < 100
            #expect(result3.hasMorePages == true)  // 50 < 100
        }
    }

    @Suite("Sendable Tests")
    struct SendableTests {
        @Test("ProductSearchResult can be used across concurrency boundaries")
        func testSendable() async {
            // Arrange
            let searchResult = ProductSearchResult(
                products: [],
                totalCount: 10,
                page: 1,
                pageSize: 10
            )

            // Act
            await withCheckedContinuation { continuation in
                Task {
                    // This would fail to compile if ProductSearchResult wasn't Sendable
                    let result = searchResult
                    #expect(result.totalCount == 10)
                    continuation.resume()
                }
            }
        }
    }
}
