//
//  ScannedProduct.swift
//  vitamin_calculator
//
//  Created by TDD on 26.01.26.
//

import Foundation

/// Represents a product scanned from an external API (e.g., Open Food Facts).
/// Contains product information and nutritional data that can be converted to local models.
struct ScannedProduct: Hashable, Sendable {
    // MARK: - Properties

    /// The barcode/EAN of the product
    let barcode: String

    /// Product name
    let name: String

    /// Brand name (optional)
    let brand: String?

    /// URL to product image (optional)
    let imageUrl: String?

    /// Serving size description (e.g., "1 tablet", "15g")
    let servingSize: String?

    /// Array of nutrients found in the product
    let nutrients: [ScannedNutrient]

    // MARK: - Initialization

    /// Creates a new scanned product with the specified properties
    /// - Parameters:
    ///   - barcode: The barcode/EAN of the product
    ///   - name: Product name
    ///   - brand: Brand name (optional)
    ///   - imageUrl: URL to product image (optional)
    ///   - servingSize: Serving size description (optional)
    ///   - nutrients: Array of nutrients found in the product
    init(
        barcode: String,
        name: String,
        brand: String?,
        imageUrl: String?,
        servingSize: String?,
        nutrients: [ScannedNutrient]
    ) {
        self.barcode = barcode
        self.name = name
        self.brand = brand
        self.imageUrl = imageUrl
        self.servingSize = servingSize
        self.nutrients = nutrients
    }

    // MARK: - Codable Conformance

    enum CodingKeys: String, CodingKey {
        case barcode
        case name
        case brand
        case imageUrl
        case servingSize
        case nutrients
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.barcode = try container.decode(String.self, forKey: .barcode)
        self.name = try container.decode(String.self, forKey: .name)
        self.brand = try container.decodeIfPresent(String.self, forKey: .brand)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.servingSize = try container.decodeIfPresent(String.self, forKey: .servingSize)
        self.nutrients = try container.decode([ScannedNutrient].self, forKey: .nutrients)
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(barcode, forKey: .barcode)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(brand, forKey: .brand)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(servingSize, forKey: .servingSize)
        try container.encode(nutrients, forKey: .nutrients)
    }
}

    // MARK: - Conversion Methods

    /// Converts the scanned nutrients to local Nutrient models
    /// Only includes nutrients that can be mapped to known NutrientType
    /// - Returns: Array of mapped Nutrient objects
    func toNutrients() -> [Nutrient] {
        return nutrients.compactMap { $0.toNutrient() }
    }
}

// MARK: - Codable Conformance
extension ScannedProduct: Codable {}

/// Represents a single nutrient from an external API.
/// Can be mapped to a local NutrientType if recognized.
struct ScannedNutrient: Hashable, Sendable {
    // MARK: - Properties

    /// Nutrient name as provided by the external API
    let name: String

    /// Amount of the nutrient
    let amount: Double

    /// Unit of measurement (e.g., "mg", "μg")
    let unit: String

    // MARK: - Initialization

    /// Creates a new scanned nutrient
    /// - Parameters:
    ///   - name: Nutrient name as provided by the external API
    ///   - amount: Amount of the nutrient
    ///   - unit: Unit of measurement
    init(name: String, amount: Double, unit: String) {
        self.name = name
        self.amount = amount
        self.unit = unit
    }

    // MARK: - Codable Conformance

    enum CodingKeys: String, CodingKey {
        case name
        case amount
        case unit
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.unit = try container.decode(String.self, forKey: .unit)
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(amount, forKey: .amount)
        try container.encode(unit, forKey: .unit)
    }

    // MARK: - Conversion Methods

    /// Attempts to map the external nutrient name to a local NutrientType
    /// - Returns: A Nutrient object if mapping succeeds, nil otherwise
    func toNutrient() -> Nutrient? {
        guard let nutrientType = mapToNutrientType() else {
            return nil
        }
        return Nutrient(type: nutrientType, amount: amount)
    }

    /// Maps the external nutrient name to NutrientType
    /// Supports various naming conventions from Open Food Facts API
    /// - Returns: Matching NutrientType or nil if not recognized
    private func mapToNutrientType() -> NutrientType? {
        let normalizedName = name.lowercased()
            .replacingOccurrences(of: "_", with: "-")
            .trimmingCharacters(in: .whitespaces)

        // Map common Open Food Facts naming to our NutrientType
        switch normalizedName {
        // Vitamins
        case "vitamin-a", "vitamin a", "retinol":
            return .vitaminA
        case "vitamin-d", "vitamin d", "calciferol":
            return .vitaminD
        case "vitamin-e", "vitamin e", "tocopherol":
            return .vitaminE
        case "vitamin-k", "vitamin k":
            return .vitaminK
        case "vitamin-c", "vitamin c", "ascorbic-acid", "ascorbic acid":
            return .vitaminC
        case "vitamin-b1", "vitamin b1", "thiamin", "thiamine":
            return .vitaminB1
        case "vitamin-b2", "vitamin b2", "riboflavin":
            return .vitaminB2
        case "vitamin-b3", "vitamin b3", "niacin":
            return .vitaminB3
        case "vitamin-b6", "vitamin b6", "pyridoxin", "pyridoxine":
            return .vitaminB6
        case "vitamin-b12", "vitamin b12", "cobalamin":
            return .vitaminB12
        case "folate", "folic-acid", "folic acid", "folsäure":
            return .folate
        case "biotin":
            return .biotin
        case "pantothenic-acid", "pantothenic acid", "pantothensäure":
            return .pantothenicAcid

        // Minerals
        case "calcium":
            return .calcium
        case "magnesium":
            return .magnesium
        case "iron", "eisen":
            return .iron
        case "zinc", "zink":
            return .zinc
        case "selenium", "selen":
            return .selenium
        case "iodine", "jod":
            return .iodine
        case "copper", "kupfer":
            return .copper
        case "manganese", "mangan":
            return .manganese
        case "chromium", "chrom":
            return .chromium
        case "molybdenum", "molybdän":
            return .molybdenum

        default:
            return nil
        }
    }
}
// MARK: - Codable Conformance
extension ScannedNutrient: Codable {}

