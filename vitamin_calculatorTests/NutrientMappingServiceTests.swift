import Testing
import Foundation
@testable import vitamin_calculator

/// NutrientMappingService 测试套件
@Suite("NutrientMappingService Tests")
struct NutrientMappingServiceTests {

    // MARK: - Name Mapping Tests

    @Suite("Nutrient Name Mapping Tests")
    struct NameMappingTests {

        @Test("Should map vitamin A names")
        func testMapVitaminA() {
            // Arrange
            let service = NutrientMappingService()

            // Act & Assert
            #expect(service.mapToNutrientType("vitamin-a") == .vitaminA)
            #expect(service.mapToNutrientType("vitamin_a") == .vitaminA)
            #expect(service.mapToNutrientType("Vitamin A") == .vitaminA)
            #expect(service.mapToNutrientType("retinol") == .vitaminA)
        }

        @Test("Should map vitamin D names")
        func testMapVitaminD() {
            // Arrange
            let service = NutrientMappingService()

            // Act & Assert
            #expect(service.mapToNutrientType("vitamin-d") == .vitaminD)
            #expect(service.mapToNutrientType("Vitamin D") == .vitaminD)
            #expect(service.mapToNutrientType("calciferol") == .vitaminD)
        }

        @Test("Should map vitamin C names")
        func testMapVitaminC() {
            // Arrange
            let service = NutrientMappingService()

            // Act & Assert
            #expect(service.mapToNutrientType("vitamin-c") == .vitaminC)
            #expect(service.mapToNutrientType("Vitamin C") == .vitaminC)
            #expect(service.mapToNutrientType("ascorbic acid") == .vitaminC)
            #expect(service.mapToNutrientType("ascorbic-acid") == .vitaminC)
        }

        @Test("Should map B vitamin names")
        func testMapBVitamins() {
            // Arrange
            let service = NutrientMappingService()

            // Act & Assert
            #expect(service.mapToNutrientType("vitamin-b1") == .vitaminB1)
            #expect(service.mapToNutrientType("thiamin") == .vitaminB1)
            #expect(service.mapToNutrientType("thiamine") == .vitaminB1)

            #expect(service.mapToNutrientType("vitamin-b2") == .vitaminB2)
            #expect(service.mapToNutrientType("riboflavin") == .vitaminB2)

            #expect(service.mapToNutrientType("vitamin-b3") == .vitaminB3)
            #expect(service.mapToNutrientType("niacin") == .vitaminB3)

            #expect(service.mapToNutrientType("vitamin-b6") == .vitaminB6)
            #expect(service.mapToNutrientType("pyridoxine") == .vitaminB6)

            #expect(service.mapToNutrientType("vitamin-b12") == .vitaminB12)
            #expect(service.mapToNutrientType("cobalamin") == .vitaminB12)
        }

        @Test("Should map folate names")
        func testMapFolate() {
            // Arrange
            let service = NutrientMappingService()

            // Act & Assert
            #expect(service.mapToNutrientType("folate") == .folate)
            #expect(service.mapToNutrientType("folic acid") == .folate)
            #expect(service.mapToNutrientType("folic-acid") == .folate)
            #expect(service.mapToNutrientType("vitamin-b9") == .folate)
        }

        @Test("Should map mineral names")
        func testMapMinerals() {
            // Arrange
            let service = NutrientMappingService()

            // Act & Assert
            #expect(service.mapToNutrientType("calcium") == .calcium)
            #expect(service.mapToNutrientType("magnesium") == .magnesium)
            #expect(service.mapToNutrientType("iron") == .iron)
            #expect(service.mapToNutrientType("zinc") == .zinc)
            #expect(service.mapToNutrientType("selenium") == .selenium)
            #expect(service.mapToNutrientType("iodine") == .iodine)
            #expect(service.mapToNutrientType("copper") == .copper)
            #expect(service.mapToNutrientType("manganese") == .manganese)
            #expect(service.mapToNutrientType("chromium") == .chromium)
            #expect(service.mapToNutrientType("molybdenum") == .molybdenum)
        }

        @Test("Should handle case-insensitive mapping")
        func testCaseInsensitiveMapping() {
            // Arrange
            let service = NutrientMappingService()

            // Act & Assert
            #expect(service.mapToNutrientType("VITAMIN-C") == .vitaminC)
            #expect(service.mapToNutrientType("Calcium") == .calcium)
            #expect(service.mapToNutrientType("IRON") == .iron)
        }

        @Test("Should return nil for unknown nutrients")
        func testUnknownNutrient() {
            // Arrange
            let service = NutrientMappingService()

            // Act & Assert
            #expect(service.mapToNutrientType("unknown-nutrient") == nil)
            #expect(service.mapToNutrientType("protein") == nil)
            #expect(service.mapToNutrientType("carbohydrates") == nil)
        }

        @Test("Should handle empty and whitespace strings")
        func testEmptyStrings() {
            // Arrange
            let service = NutrientMappingService()

            // Act & Assert
            #expect(service.mapToNutrientType("") == nil)
            #expect(service.mapToNutrientType("   ") == nil)
        }
    }

    // MARK: - Unit Conversion Tests

    @Suite("Unit Conversion Tests")
    struct UnitConversionTests {

        @Test("Should convert mg to μg")
        func testMgToMicrograms() {
            // Arrange
            let service = NutrientMappingService()

            // Act
            let result = service.convertUnit(amount: 1.0, fromUnit: "mg", toUnit: "μg")

            // Assert
            #expect(result == 1000.0)
        }

        @Test("Should convert μg to mg")
        func testMicrogramsToMg() {
            // Arrange
            let service = NutrientMappingService()

            // Act
            let result = service.convertUnit(amount: 1000.0, fromUnit: "μg", toUnit: "mg")

            // Assert
            #expect(result == 1.0)
        }

        @Test("Should convert g to mg")
        func testGramsToMg() {
            // Arrange
            let service = NutrientMappingService()

            // Act
            let result = service.convertUnit(amount: 1.0, fromUnit: "g", toUnit: "mg")

            // Assert
            #expect(result == 1000.0)
        }

        @Test("Should convert mg to g")
        func testMgToGrams() {
            // Arrange
            let service = NutrientMappingService()

            // Act
            let result = service.convertUnit(amount: 1000.0, fromUnit: "mg", toUnit: "g")

            // Assert
            #expect(result == 1.0)
        }

        @Test("Should handle same unit conversion")
        func testSameUnitConversion() {
            // Arrange
            let service = NutrientMappingService()

            // Act
            let result = service.convertUnit(amount: 100.0, fromUnit: "mg", toUnit: "mg")

            // Assert
            #expect(result == 100.0)
        }

        @Test("Should handle alternative unit symbols")
        func testAlternativeUnitSymbols() {
            // Arrange
            let service = NutrientMappingService()

            // Act & Assert
            #expect(service.convertUnit(amount: 1.0, fromUnit: "mcg", toUnit: "mg") == 0.001)
            #expect(service.convertUnit(amount: 1.0, fromUnit: "ug", toUnit: "mg") == 0.001)
        }

        @Test("Should return nil for unknown unit conversion")
        func testUnknownUnitConversion() {
            // Arrange
            let service = NutrientMappingService()

            // Act
            let result = service.convertUnit(amount: 100.0, fromUnit: "unknown", toUnit: "mg")

            // Assert
            #expect(result == nil)
        }

        @Test("Should handle zero amount")
        func testZeroAmount() {
            // Arrange
            let service = NutrientMappingService()

            // Act
            let result = service.convertUnit(amount: 0.0, fromUnit: "mg", toUnit: "μg")

            // Assert
            #expect(result == 0.0)
        }
    }

    // MARK: - Batch Mapping Tests

    @Suite("Batch Nutrient Mapping Tests")
    struct BatchMappingTests {

        @Test("Should map multiple scanned nutrients")
        func testMapMultipleNutrients() {
            // Arrange
            let service = NutrientMappingService()
            let scannedNutrients = [
                ScannedNutrient(name: "vitamin-c", amount: 100, unit: "mg"),
                ScannedNutrient(name: "vitamin-d", amount: 20, unit: "μg"),
                ScannedNutrient(name: "calcium", amount: 500, unit: "mg")
            ]

            // Act
            let nutrients = service.mapNutrients(scannedNutrients)

            // Assert
            #expect(nutrients.count == 3)
            #expect(nutrients[0].type == .vitaminC)
            #expect(nutrients[0].amount == 100)
            #expect(nutrients[1].type == .vitaminD)
            #expect(nutrients[2].type == .calcium)
        }

        @Test("Should filter out unmappable nutrients")
        func testFilterUnmappableNutrients() {
            // Arrange
            let service = NutrientMappingService()
            let scannedNutrients = [
                ScannedNutrient(name: "vitamin-c", amount: 100, unit: "mg"),
                ScannedNutrient(name: "protein", amount: 10, unit: "g"), // Not supported
                ScannedNutrient(name: "calcium", amount: 500, unit: "mg")
            ]

            // Act
            let nutrients = service.mapNutrients(scannedNutrients)

            // Assert
            #expect(nutrients.count == 2)
            #expect(nutrients[0].type == .vitaminC)
            #expect(nutrients[1].type == .calcium)
        }

        @Test("Should handle empty scanned nutrients list")
        func testEmptyScannedNutrients() {
            // Arrange
            let service = NutrientMappingService()
            let scannedNutrients: [ScannedNutrient] = []

            // Act
            let nutrients = service.mapNutrients(scannedNutrients)

            // Assert
            #expect(nutrients.isEmpty)
        }

        @Test("Should convert units when mapping nutrients")
        func testConvertUnitsWhenMapping() {
            // Arrange
            let service = NutrientMappingService()
            let scannedNutrients = [
                // Vitamin C should stay in mg
                ScannedNutrient(name: "vitamin-c", amount: 100, unit: "mg"),
                // Vitamin D should stay in μg
                ScannedNutrient(name: "vitamin-d", amount: 20, unit: "μg"),
                // Vitamin A in mg should convert to μg
                ScannedNutrient(name: "vitamin-a", amount: 1.0, unit: "mg")
            ]

            // Act
            let nutrients = service.mapNutrients(scannedNutrients)

            // Assert
            #expect(nutrients.count == 3)
            // Vitamin C: mg stays mg
            #expect(nutrients[0].amount == 100)
            // Vitamin D: μg stays μg
            #expect(nutrients[1].amount == 20)
            // Vitamin A: 1 mg = 1000 μg
            #expect(nutrients[2].amount == 1000)
        }
    }
}
