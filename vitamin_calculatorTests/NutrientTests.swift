//
//  NutrientTests.swift
//  vitamin_calculatorTests
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("Nutrient Model Tests")
struct NutrientTests {

    @Suite("Initialization Tests")
    struct InitializationTests {
        @Test("Nutrient should store basic properties")
        func testNutrientProperties() {
            // Arrange & Act
            let nutrient = Nutrient(
                type: .vitaminC,
                amount: 100.0
            )

            // Assert
            #expect(nutrient.type == .vitaminC)
            #expect(nutrient.amount == 100.0)
        }

        @Test("Nutrient should handle zero amount")
        func testNutrientZeroAmount() {
            // Arrange & Act
            let nutrient = Nutrient(
                type: .vitaminD,
                amount: 0
            )

            // Assert
            #expect(nutrient.amount == 0)
        }

        @Test("Nutrient should handle decimal amounts")
        func testNutrientDecimalAmount() {
            // Arrange & Act
            let nutrient = Nutrient(
                type: .vitaminA,
                amount: 123.456
            )

            // Assert
            #expect(nutrient.amount == 123.456)
        }

        @Test("Nutrient should handle large amounts")
        func testNutrientLargeAmount() {
            // Arrange & Act
            let nutrient = Nutrient(
                type: .calcium,
                amount: 10000.0
            )

            // Assert
            #expect(nutrient.amount == 10000.0)
        }
    }

    @Suite("Property Access Tests")
    struct PropertyAccessTests {
        @Test("Nutrient should provide access to type")
        func testTypeAccess() {
            // Arrange
            let nutrient = Nutrient(type: .zinc, amount: 15.0)

            // Act & Assert
            #expect(nutrient.type == .zinc)
        }

        @Test("Nutrient should provide access to amount")
        func testAmountAccess() {
            // Arrange
            let nutrient = Nutrient(type: .iron, amount: 8.0)

            // Act & Assert
            #expect(nutrient.amount == 8.0)
        }

        @Test("Nutrient should provide localized name through type")
        func testLocalizedNameAccess() {
            // Arrange
            let nutrient = Nutrient(type: .vitaminC, amount: 100.0)

            // Act
            let localizedName = nutrient.type.localizedName

            // Assert
            #expect(!localizedName.isEmpty)
        }

        @Test("Nutrient should provide unit through type")
        func testUnitAccess() {
            // Arrange
            let nutrient = Nutrient(type: .vitaminD, amount: 20.0)

            // Act
            let unit = nutrient.type.unit

            // Assert
            #expect(unit == "μg")
        }
    }

    @Suite("Equality and Comparison Tests")
    struct EqualityTests {
        @Test("Two nutrients with same type and amount should be equal")
        func testNutrientEquality() {
            // Arrange
            let nutrient1 = Nutrient(type: .vitaminC, amount: 100.0)
            let nutrient2 = Nutrient(type: .vitaminC, amount: 100.0)

            // Act & Assert
            #expect(nutrient1.type == nutrient2.type)
            #expect(nutrient1.amount == nutrient2.amount)
        }

        @Test("Two nutrients with different types should not be equal")
        func testNutrientInequalityByType() {
            // Arrange
            let nutrient1 = Nutrient(type: .vitaminC, amount: 100.0)
            let nutrient2 = Nutrient(type: .vitaminD, amount: 100.0)

            // Act & Assert
            #expect(nutrient1.type != nutrient2.type)
        }

        @Test("Two nutrients with different amounts should not be equal")
        func testNutrientInequalityByAmount() {
            // Arrange
            let nutrient1 = Nutrient(type: .vitaminC, amount: 100.0)
            let nutrient2 = Nutrient(type: .vitaminC, amount: 200.0)

            // Act & Assert
            #expect(nutrient1.amount != nutrient2.amount)
        }
    }

    @Suite("Edge Case Tests")
    struct EdgeCaseTests {
        @Test("Nutrient should handle very small amounts")
        func testVerySmallAmount() {
            // Arrange & Act
            let nutrient = Nutrient(type: .vitaminB12, amount: 0.001)

            // Assert
            #expect(nutrient.amount == 0.001)
        }

        @Test("Nutrient should handle all nutrient types")
        func testAllNutrientTypes() {
            // Arrange & Act
            for nutrientType in NutrientType.allCases {
                let nutrient = Nutrient(type: nutrientType, amount: 50.0)

                // Assert
                #expect(nutrient.type == nutrientType)
                #expect(nutrient.amount == 50.0)
            }
        }
    }

    @Suite("Codable Tests")
    struct CodableTests {
        @Test("Nutrient should be encodable")
        func testNutrientEncoding() throws {
            // Arrange
            let nutrient = Nutrient(type: .vitaminC, amount: 100.0)
            let encoder = JSONEncoder()

            // Act & Assert
            let data = try encoder.encode(nutrient)
            #expect(!data.isEmpty)
        }

        @Test("Nutrient should be decodable")
        func testNutrientDecoding() throws {
            // Arrange
            let original = Nutrient(type: .calcium, amount: 500.0)
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(Nutrient.self, from: data)

            // Assert
            #expect(decoded.type == original.type)
            #expect(decoded.amount == original.amount)
        }

        @Test("Nutrient should round-trip encode and decode")
        func testNutrientRoundTrip() throws {
            // Arrange
            let nutrients = [
                Nutrient(type: .vitaminA, amount: 800.0),
                Nutrient(type: .vitaminD, amount: 20.0),
                Nutrient(type: .calcium, amount: 1000.0)
            ]
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act & Assert
            for nutrient in nutrients {
                let data = try encoder.encode(nutrient)
                let decoded = try decoder.decode(Nutrient.self, from: data)

                #expect(decoded.type == nutrient.type)
                #expect(decoded.amount == nutrient.amount)
            }
        }
    }
}
