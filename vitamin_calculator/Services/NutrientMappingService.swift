import Foundation

/// Service for mapping external nutrient names to local NutrientType enum.
/// Handles name normalization, unit conversion, and batch mapping operations.
final class NutrientMappingService: Sendable {

    // MARK: - Properties

    /// Mapping dictionary from external names to NutrientType
    /// Supports various formats: hyphenated, underscored, spaced, and alternative names
    private let nutrientNameMapping: [String: NutrientType] = [
        // Vitamin A
        "vitamin-a": .vitaminA,
        "vitamin_a": .vitaminA,
        "vitamin a": .vitaminA,
        "retinol": .vitaminA,

        // Vitamin D
        "vitamin-d": .vitaminD,
        "vitamin_d": .vitaminD,
        "vitamin d": .vitaminD,
        "calciferol": .vitaminD,

        // Vitamin E
        "vitamin-e": .vitaminE,
        "vitamin_e": .vitaminE,
        "vitamin e": .vitaminE,
        "tocopherol": .vitaminE,

        // Vitamin K
        "vitamin-k": .vitaminK,
        "vitamin_k": .vitaminK,
        "vitamin k": .vitaminK,

        // Vitamin C
        "vitamin-c": .vitaminC,
        "vitamin_c": .vitaminC,
        "vitamin c": .vitaminC,
        "ascorbic acid": .vitaminC,
        "ascorbic-acid": .vitaminC,

        // Vitamin B1
        "vitamin-b1": .vitaminB1,
        "vitamin_b1": .vitaminB1,
        "vitamin b1": .vitaminB1,
        "thiamin": .vitaminB1,
        "thiamine": .vitaminB1,

        // Vitamin B2
        "vitamin-b2": .vitaminB2,
        "vitamin_b2": .vitaminB2,
        "vitamin b2": .vitaminB2,
        "riboflavin": .vitaminB2,

        // Vitamin B3
        "vitamin-b3": .vitaminB3,
        "vitamin_b3": .vitaminB3,
        "vitamin b3": .vitaminB3,
        "niacin": .vitaminB3,

        // Vitamin B6
        "vitamin-b6": .vitaminB6,
        "vitamin_b6": .vitaminB6,
        "vitamin b6": .vitaminB6,
        "pyridoxine": .vitaminB6,
        "pyridoxin": .vitaminB6,

        // Vitamin B12
        "vitamin-b12": .vitaminB12,
        "vitamin_b12": .vitaminB12,
        "vitamin b12": .vitaminB12,
        "cobalamin": .vitaminB12,

        // Folate (Vitamin B9)
        "folate": .folate,
        "folic acid": .folate,
        "folic-acid": .folate,
        "vitamin-b9": .folate,
        "vitamin_b9": .folate,
        "vitamin b9": .folate,

        // Biotin (Vitamin B7)
        "biotin": .biotin,
        "vitamin-b7": .biotin,
        "vitamin_b7": .biotin,
        "vitamin b7": .biotin,

        // Pantothenic Acid (Vitamin B5)
        "pantothenic acid": .pantothenicAcid,
        "pantothenic-acid": .pantothenicAcid,
        "vitamin-b5": .pantothenicAcid,
        "vitamin_b5": .pantothenicAcid,
        "vitamin b5": .pantothenicAcid,

        // Minerals
        "calcium": .calcium,
        "magnesium": .magnesium,
        "iron": .iron,
        "zinc": .zinc,
        "selenium": .selenium,
        "iodine": .iodine,
        "copper": .copper,
        "manganese": .manganese,
        "chromium": .chromium,
        "molybdenum": .molybdenum
    ]

    /// Unit conversion factors to base unit (mg)
    private let unitConversionFactors: [String: Double] = [
        "g": 1000.0,        // 1 g = 1000 mg
        "mg": 1.0,          // Base unit
        "μg": 0.001,        // 1 μg = 0.001 mg
        "mcg": 0.001,       // Alternative micrograms
        "ug": 0.001         // Alternative micrograms
    ]

    // MARK: - Initialization

    init() {}

    // MARK: - Name Mapping

    /// Maps an external nutrient name to a local NutrientType
    /// - Parameter externalName: The nutrient name from external API
    /// - Returns: Corresponding NutrientType if mapping exists, nil otherwise
    func mapToNutrientType(_ externalName: String) -> NutrientType? {
        // Normalize: lowercase and trim whitespace
        let normalized = externalName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Return nil for empty strings
        guard !normalized.isEmpty else { return nil }

        return nutrientNameMapping[normalized]
    }

    // MARK: - Unit Conversion

    /// Converts an amount from one unit to another
    /// - Parameters:
    ///   - amount: The amount to convert
    ///   - fromUnit: Source unit (e.g., "mg", "μg", "g")
    ///   - toUnit: Target unit
    /// - Returns: Converted amount, or nil if conversion not possible
    func convertUnit(amount: Double, fromUnit: String, toUnit: String) -> Double? {
        // Normalize unit strings
        let normalizedFrom = fromUnit.lowercased()
        let normalizedTo = toUnit.lowercased()

        // Same unit, no conversion needed
        if normalizedFrom == normalizedTo {
            return amount
        }

        // Get conversion factors
        guard let fromFactor = unitConversionFactors[normalizedFrom],
              let toFactor = unitConversionFactors[normalizedTo] else {
            return nil
        }

        // Convert: amount -> mg -> target unit
        let amountInMg = amount * fromFactor
        return amountInMg / toFactor
    }

    // MARK: - Batch Mapping

    /// Maps a list of scanned nutrients to local Nutrient models
    /// Only includes nutrients that can be successfully mapped
    /// - Parameter scannedNutrients: Array of scanned nutrients from external API
    /// - Returns: Array of mapped Nutrient objects
    func mapNutrients(_ scannedNutrients: [ScannedNutrient]) -> [Nutrient] {
        return scannedNutrients.compactMap { scanned in
            // Try to map the nutrient type
            guard let nutrientType = mapToNutrientType(scanned.name) else {
                return nil
            }

            // Get the expected unit for this nutrient type
            let expectedUnit = nutrientType.unit

            // Convert amount to expected unit if needed
            var finalAmount = scanned.amount
            if scanned.unit.lowercased() != expectedUnit.lowercased() {
                if let converted = convertUnit(
                    amount: scanned.amount,
                    fromUnit: scanned.unit,
                    toUnit: expectedUnit
                ) {
                    finalAmount = converted
                } else {
                    // If conversion fails, skip this nutrient
                    return nil
                }
            }

            // Create and return the Nutrient
            return Nutrient(type: nutrientType, amount: finalAmount)
        }
    }
}
