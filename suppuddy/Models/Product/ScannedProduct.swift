//
//  ScannedProduct.swift
//  suppuddy
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

    /// Keys matching the Open Food Facts API v2 response format
    enum CodingKeys: String, CodingKey {
        case barcode = "code"
        case name = "product_name"
        case brand = "brands"
        case imageUrl = "image_url"
        case servingSize = "serving_size"
        case nutriments
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.barcode = try container.decode(String.self, forKey: .barcode)
        self.name = (try? container.decode(String.self, forKey: .name)) ?? "Unknown Product"
        self.brand = try container.decodeIfPresent(String.self, forKey: .brand)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.servingSize = try container.decodeIfPresent(String.self, forKey: .servingSize)

        // Parse nutriments: try flat dictionary (API format) first, then array (internal export format)
        if let nutrimentsDict = try? container.decode([String: AnyCodableValue].self, forKey: .nutriments) {
            self.nutrients = ScannedProduct.parseNutriments(nutrimentsDict)
        } else if let nutrientsArray = try? container.decode([ScannedNutrient].self, forKey: .nutriments) {
            // Normalize cached/exported data — older caches may store raw gram values
            self.nutrients = nutrientsArray.map { $0.normalized() }
        } else {
            self.nutrients = []
        }
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(barcode, forKey: .barcode)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(brand, forKey: .brand)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(servingSize, forKey: .servingSize)
        // Encode nutrients as a simple array for export/import
        var nutrimentsContainer = container.nestedUnkeyedContainer(forKey: .nutriments)
        for nutrient in nutrients {
            try nutrimentsContainer.encode(nutrient)
        }
    }

    // MARK: - Nutriments Parsing

    /// Parses the flat Open Food Facts nutriments dictionary into ScannedNutrient array.
    /// The API returns values in grams by default. This method converts them to the
    /// appropriate unit (mg or μg) matching NutrientType expectations.
    /// Prefers _serving values (best for supplements), then _100g, then base key.
    private nonisolated static func parseNutriments(_ dict: [String: AnyCodableValue]) -> [ScannedNutrient] {
        // OFF key → (internal name, target unit matching NutrientType.unit)
        let nutrientDefs: [(key: String, name: String, targetUnit: String)] = [
            ("vitamin-a",       "vitamin-a",       "μg"),
            ("vitamin-d",       "vitamin-d",       "μg"),
            ("vitamin-e",       "vitamin-e",       "mg"),
            ("vitamin-k",       "vitamin-k",       "μg"),
            ("vitamin-c",       "vitamin-c",       "mg"),
            ("vitamin-b1",      "vitamin-b1",      "mg"),
            ("vitamin-b2",      "vitamin-b2",      "mg"),
            ("vitamin-pp",      "niacin",          "mg"),
            ("vitamin-b6",      "vitamin-b6",      "mg"),
            ("vitamin-b12",     "vitamin-b12",     "μg"),
            ("folates",         "folate",          "μg"),
            ("biotin",          "biotin",          "μg"),
            ("pantothenic-acid","pantothenic-acid", "mg"),
            ("calcium",         "calcium",         "mg"),
            ("magnesium",       "magnesium",       "mg"),
            ("iron",            "iron",            "mg"),
            ("zinc",            "zinc",            "mg"),
            ("selenium",        "selenium",        "μg"),
            ("iodine",          "iodine",          "μg"),
            ("copper",          "copper",          "mg"),
            ("manganese",       "manganese",       "mg"),
            ("chromium",        "chromium",        "μg"),
            ("molybdenum",      "molybdenum",      "μg"),
        ]

        var nutrients: [ScannedNutrient] = []

        for def in nutrientDefs {
            let key = def.key

            // Prefer _serving (best for supplements), then _100g, then base key
            let rawAmount: Double?
            if let val = dict["\(key)_serving"]?.doubleValue {
                rawAmount = val
            } else if let val = dict["\(key)_100g"]?.doubleValue {
                rawAmount = val
            } else if let val = dict[key]?.doubleValue {
                rawAmount = val
            } else {
                continue
            }

            guard let amt = rawAmount, amt > 0 else { continue }

            // The API unit for this nutrient (OFF typically stores values in grams)
            let apiUnit = dict["\(key)_unit"]?.stringValue ?? "g"

            // Convert from API unit to the target unit expected by NutrientType
            let convertedAmount = ScannedNutrient.convertAmount(amt, from: apiUnit, to: def.targetUnit)
            guard convertedAmount > 0 else { continue }

            nutrients.append(ScannedNutrient(name: def.name, amount: convertedAmount, unit: def.targetUnit))
        }

        return nutrients
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

// MARK: - Identifiable Conformance
extension ScannedProduct: Identifiable {
    var id: String { barcode }
}

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
    nonisolated init(name: String, amount: Double, unit: String) {
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

    // MARK: - Unit Conversion

    /// Converts a nutrient amount between units (g, mg, μg).
    nonisolated static func convertAmount(_ amount: Double, from sourceUnit: String, to targetUnit: String) -> Double {
        let source = sourceUnit.lowercased().trimmingCharacters(in: .whitespaces)
        let target = targetUnit.lowercased().trimmingCharacters(in: .whitespaces)
        if source == target { return amount }

        let sourceToGrams: Double
        switch source {
        case "g":               sourceToGrams = 1
        case "mg":              sourceToGrams = 1e-3
        case "μg", "ug", "mcg": sourceToGrams = 1e-6
        default:                sourceToGrams = 1e-3 // assume mg
        }

        let gramsToTarget: Double
        switch target {
        case "g":               gramsToTarget = 1
        case "mg":              gramsToTarget = 1e3
        case "μg", "ug", "mcg": gramsToTarget = 1e6
        default:                gramsToTarget = 1e3 // assume mg
        }

        return amount * sourceToGrams * gramsToTarget
    }

    /// Returns a copy with the amount converted to the NutrientType's expected unit.
    /// For example, 0.012 g of vitamin-e becomes 12.0 mg.
    /// If the nutrient can't be mapped or is already in the correct unit, returns self.
    nonisolated func normalized() -> ScannedNutrient {
        guard let nutrientType = mapToNutrientType() else { return self }
        let targetUnit = nutrientType.unit
        if unit == targetUnit { return self }
        let convertedAmount = ScannedNutrient.convertAmount(amount, from: unit, to: targetUnit)
        return ScannedNutrient(name: name, amount: convertedAmount, unit: targetUnit)
    }

    // MARK: - Conversion Methods

    /// Attempts to map the external nutrient name to a local NutrientType.
    /// Converts the amount to match the NutrientType's expected unit.
    /// - Returns: A Nutrient object if mapping succeeds, nil otherwise
    nonisolated func toNutrient() -> Nutrient? {
        guard let nutrientType = mapToNutrientType() else {
            return nil
        }
        let convertedAmount = ScannedNutrient.convertAmount(amount, from: unit, to: nutrientType.unit)
        return Nutrient(type: nutrientType, amount: convertedAmount)
    }

    /// Maps the external nutrient name to NutrientType
    /// Supports various naming conventions from Open Food Facts API
    /// - Returns: Matching NutrientType or nil if not recognized
    nonisolated func mapToNutrientType() -> NutrientType? {
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

// MARK: - AnyCodableValue

/// A helper type to decode JSON values that can be numbers, strings, or booleans.
/// Used for parsing Open Food Facts nutriments dictionary where values have mixed types.
enum AnyCodableValue: Sendable, Decodable {
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .int(intVal)
        } else if let doubleVal = try? container.decode(Double.self) {
            self = .double(doubleVal)
        } else if let stringVal = try? container.decode(String.self) {
            self = .string(stringVal)
        } else if let boolVal = try? container.decode(Bool.self) {
            self = .bool(boolVal)
        } else {
            self = .string("")
        }
    }

    nonisolated var doubleValue: Double? {
        switch self {
        case .int(let v): return Double(v)
        case .double(let v): return v
        case .string(let v): return Double(v)
        case .bool: return nil
        }
    }

    nonisolated var stringValue: String? {
        switch self {
        case .string(let v): return v
        case .int(let v): return String(v)
        case .double(let v): return String(v)
        case .bool: return nil
        }
    }
}
