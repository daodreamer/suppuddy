//
//  ScannedProductTests.swift
//  vitamin_calculatorTests
//
//  Created by TDD on 26.01.26.
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("ScannedProduct Model Tests")
struct ScannedProductTests {

    @Suite("Initialization Tests")
    struct InitializationTests {
        @Test("ScannedProduct initializes with all required properties")
        func testScannedProductInitialization() {
            // Arrange & Act
            let nutrients = [
                ScannedNutrient(name: "Vitamin C", amount: 100.0, unit: "mg")
            ]
            let product = ScannedProduct(
                barcode: "1234567890123",
                name: "Test Supplement",
                brand: "Test Brand",
                imageUrl: "https://example.com/image.jpg",
                servingSize: "1 tablet",
                nutrients: nutrients
            )

            // Assert
            #expect(product.barcode == "1234567890123")
            #expect(product.name == "Test Supplement")
            #expect(product.brand == "Test Brand")
            #expect(product.imageUrl == "https://example.com/image.jpg")
            #expect(product.servingSize == "1 tablet")
            #expect(product.nutrients.count == 1)
        }

        @Test("ScannedProduct initializes with optional nil values")
        func testScannedProductWithNilOptionals() {
            // Arrange & Act
            let product = ScannedProduct(
                barcode: "1234567890123",
                name: "Basic Product",
                brand: nil,
                imageUrl: nil,
                servingSize: nil,
                nutrients: []
            )

            // Assert
            #expect(product.barcode == "1234567890123")
            #expect(product.name == "Basic Product")
            #expect(product.brand == nil)
            #expect(product.imageUrl == nil)
            #expect(product.servingSize == nil)
            #expect(product.nutrients.isEmpty)
        }

        @Test("ScannedProduct handles empty nutrients array")
        func testScannedProductEmptyNutrients() {
            // Arrange & Act
            let product = ScannedProduct(
                barcode: "9999999999999",
                name: "Empty Product",
                brand: nil,
                imageUrl: nil,
                servingSize: nil,
                nutrients: []
            )

            // Assert
            #expect(product.nutrients.isEmpty)
        }
    }

    @Suite("ScannedNutrient Tests")
    struct ScannedNutrientTests {
        @Test("ScannedNutrient initializes with all properties")
        func testScannedNutrientInitialization() {
            // Arrange & Act
            let nutrient = ScannedNutrient(
                name: "Vitamin D",
                amount: 25.0,
                unit: "μg"
            )

            // Assert
            #expect(nutrient.name == "Vitamin D")
            #expect(nutrient.amount == 25.0)
            #expect(nutrient.unit == "μg")
        }

        @Test("ScannedNutrient handles zero amount")
        func testScannedNutrientZeroAmount() {
            // Arrange & Act
            let nutrient = ScannedNutrient(
                name: "Iron",
                amount: 0.0,
                unit: "mg"
            )

            // Assert
            #expect(nutrient.amount == 0.0)
        }

        @Test("ScannedNutrient handles decimal amounts")
        func testScannedNutrientDecimalAmount() {
            // Arrange & Act
            let nutrient = ScannedNutrient(
                name: "Selenium",
                amount: 55.5,
                unit: "μg"
            )

            // Assert
            #expect(nutrient.amount == 55.5)
        }

        @Test("ScannedNutrient maps to NutrientType for known vitamins")
        func testScannedNutrientMappingVitaminC() {
            // Arrange
            let scannedNutrient = ScannedNutrient(
                name: "vitamin-c",
                amount: 100.0,
                unit: "mg"
            )

            // Act
            let nutrient = scannedNutrient.toNutrient()

            // Assert
            #expect(nutrient != nil)
            #expect(nutrient?.type == .vitaminC)
            #expect(nutrient?.amount == 100.0)
        }

        @Test("ScannedNutrient maps to NutrientType for vitamin D")
        func testScannedNutrientMappingVitaminD() {
            // Arrange
            let scannedNutrient = ScannedNutrient(
                name: "vitamin-d",
                amount: 20.0,
                unit: "μg"
            )

            // Act
            let nutrient = scannedNutrient.toNutrient()

            // Assert
            #expect(nutrient != nil)
            #expect(nutrient?.type == .vitaminD)
            #expect(nutrient?.amount == 20.0)
        }

        @Test("ScannedNutrient returns nil for unknown nutrients")
        func testScannedNutrientUnknownMapping() {
            // Arrange
            let scannedNutrient = ScannedNutrient(
                name: "unknown-nutrient",
                amount: 50.0,
                unit: "mg"
            )

            // Act
            let nutrient = scannedNutrient.toNutrient()

            // Assert
            #expect(nutrient == nil)
        }
    }

    @Suite("Codable Tests")
    struct CodableTests {
        @Test("ScannedProduct should be encodable")
        func testScannedProductEncoding() throws {
            // Arrange
            let nutrients = [
                ScannedNutrient(name: "Vitamin C", amount: 100.0, unit: "mg")
            ]
            let product = ScannedProduct(
                barcode: "1234567890123",
                name: "Test Product",
                brand: "Test Brand",
                imageUrl: "https://example.com/image.jpg",
                servingSize: "1 tablet",
                nutrients: nutrients
            )
            let encoder = JSONEncoder()

            // Act
            let data = try encoder.encode(product)

            // Assert
            #expect(!data.isEmpty)
        }

        @Test("ScannedProduct should be decodable")
        func testScannedProductDecoding() throws {
            // Arrange
            let nutrients = [
                ScannedNutrient(name: "Vitamin D", amount: 25.0, unit: "μg")
            ]
            let original = ScannedProduct(
                barcode: "9876543210987",
                name: "Original Product",
                brand: "Brand X",
                imageUrl: nil,
                servingSize: "2 capsules",
                nutrients: nutrients
            )
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(ScannedProduct.self, from: data)

            // Assert
            #expect(decoded.barcode == original.barcode)
            #expect(decoded.name == original.name)
            #expect(decoded.brand == original.brand)
            #expect(decoded.servingSize == original.servingSize)
            #expect(decoded.nutrients.count == original.nutrients.count)
        }

        @Test("ScannedProduct should round-trip encode and decode")
        func testScannedProductRoundTrip() throws {
            // Arrange
            let products = [
                ScannedProduct(
                    barcode: "111",
                    name: "Product 1",
                    brand: "Brand 1",
                    imageUrl: "url1",
                    servingSize: "1 serving",
                    nutrients: [ScannedNutrient(name: "Vitamin A", amount: 800.0, unit: "μg")]
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
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act & Assert
            for product in products {
                let data = try encoder.encode(product)
                let decoded = try decoder.decode(ScannedProduct.self, from: data)

                #expect(decoded.barcode == product.barcode)
                #expect(decoded.name == product.name)
                #expect(decoded.brand == product.brand)
            }
        }

        @Test("ScannedNutrient should be encodable and decodable")
        func testScannedNutrientCodable() throws {
            // Arrange
            let original = ScannedNutrient(
                name: "Calcium",
                amount: 500.0,
                unit: "mg"
            )
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(ScannedNutrient.self, from: data)

            // Assert
            #expect(decoded.name == original.name)
            #expect(decoded.amount == original.amount)
            #expect(decoded.unit == original.unit)
        }
    }

    @Suite("API Response Parsing Tests")
    struct APIParsingTests {
        @Test("ScannedProduct should parse from Open Food Facts JSON structure")
        func testOpenFoodFactsJSONParsing() throws {
            // Arrange
            let jsonString = """
            {
                "barcode": "3017620422003",
                "name": "Nutella",
                "brand": "Ferrero",
                "imageUrl": "https://example.com/nutella.jpg",
                "servingSize": "15g",
                "nutrients": [
                    {
                        "name": "vitamin-c",
                        "amount": 10.0,
                        "unit": "mg"
                    },
                    {
                        "name": "calcium",
                        "amount": 62.0,
                        "unit": "mg"
                    }
                ]
            }
            """
            let jsonData = jsonString.data(using: .utf8)!
            let decoder = JSONDecoder()

            // Act
            let product = try decoder.decode(ScannedProduct.self, from: jsonData)

            // Assert
            #expect(product.barcode == "3017620422003")
            #expect(product.name == "Nutella")
            #expect(product.brand == "Ferrero")
            #expect(product.nutrients.count == 2)
        }

        @Test("ScannedProduct should handle missing optional fields in JSON")
        func testJSONParsingWithMissingOptionals() throws {
            // Arrange
            let jsonString = """
            {
                "barcode": "1234567890",
                "name": "Basic Product",
                "nutrients": []
            }
            """
            let jsonData = jsonString.data(using: .utf8)!
            let decoder = JSONDecoder()

            // Act
            let product = try decoder.decode(ScannedProduct.self, from: jsonData)

            // Assert
            #expect(product.barcode == "1234567890")
            #expect(product.name == "Basic Product")
            #expect(product.brand == nil)
            #expect(product.imageUrl == nil)
            #expect(product.servingSize == nil)
            #expect(product.nutrients.isEmpty)
        }
    }

    @Suite("Conversion Tests")
    struct ConversionTests {
        @Test("ScannedProduct converts to local Nutrient array")
        func testConversionToNutrients() {
            // Arrange
            let scannedProduct = ScannedProduct(
                barcode: "123",
                name: "Multi Vitamin",
                brand: "Brand",
                imageUrl: nil,
                servingSize: "1 tablet",
                nutrients: [
                    ScannedNutrient(name: "vitamin-c", amount: 100.0, unit: "mg"),
                    ScannedNutrient(name: "vitamin-d", amount: 20.0, unit: "μg"),
                    ScannedNutrient(name: "unknown-nutrient", amount: 50.0, unit: "mg")
                ]
            )

            // Act
            let nutrients = scannedProduct.toNutrients()

            // Assert
            // Should only include mapped nutrients, excluding unknown ones
            #expect(nutrients.count == 2)
            #expect(nutrients.contains { $0.type == .vitaminC })
            #expect(nutrients.contains { $0.type == .vitaminD })
        }

        @Test("ScannedProduct with no mappable nutrients returns empty array")
        func testConversionWithNoMappableNutrients() {
            // Arrange
            let scannedProduct = ScannedProduct(
                barcode: "999",
                name: "Unknown Product",
                brand: nil,
                imageUrl: nil,
                servingSize: nil,
                nutrients: [
                    ScannedNutrient(name: "unknown-1", amount: 10.0, unit: "mg"),
                    ScannedNutrient(name: "unknown-2", amount: 20.0, unit: "mg")
                ]
            )

            // Act
            let nutrients = scannedProduct.toNutrients()

            // Assert
            #expect(nutrients.isEmpty)
        }
    }

    @Suite("Hashable and Equatable Tests")
    struct HashableTests {
        @Test("Two ScannedProducts with same data should be equal")
        func testScannedProductEquality() {
            // Arrange
            let nutrients = [ScannedNutrient(name: "Vitamin C", amount: 100.0, unit: "mg")]
            let product1 = ScannedProduct(
                barcode: "123",
                name: "Product",
                brand: "Brand",
                imageUrl: nil,
                servingSize: "1 serving",
                nutrients: nutrients
            )
            let product2 = ScannedProduct(
                barcode: "123",
                name: "Product",
                brand: "Brand",
                imageUrl: nil,
                servingSize: "1 serving",
                nutrients: nutrients
            )

            // Act & Assert
            #expect(product1 == product2)
        }

        @Test("Two ScannedProducts with different barcodes should not be equal")
        func testScannedProductInequalityByBarcode() {
            // Arrange
            let product1 = ScannedProduct(
                barcode: "111",
                name: "Product",
                brand: nil,
                imageUrl: nil,
                servingSize: nil,
                nutrients: []
            )
            let product2 = ScannedProduct(
                barcode: "222",
                name: "Product",
                brand: nil,
                imageUrl: nil,
                servingSize: nil,
                nutrients: []
            )

            // Act & Assert
            #expect(product1 != product2)
        }
    }
}
