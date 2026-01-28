//
//  NutrientType.swift
//  vitamin_calculator
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Foundation

/// Represents different types of nutrients (vitamins and minerals) tracked by the app.
/// Based on German DGE (Deutsche Gesellschaft für Ernährung) standards.
enum NutrientType: String, CaseIterable, Codable, Hashable, Sendable {
    // MARK: - Vitamins

    /// Vitamin A (Retinol)
    case vitaminA

    /// Vitamin D (Calciferol)
    case vitaminD

    /// Vitamin E (Tocopherol)
    case vitaminE

    /// Vitamin K
    case vitaminK

    /// Vitamin C (Ascorbic Acid)
    case vitaminC

    /// Vitamin B1 (Thiamin)
    case vitaminB1

    /// Vitamin B2 (Riboflavin)
    case vitaminB2

    /// Vitamin B3 (Niacin)
    case vitaminB3

    /// Vitamin B6 (Pyridoxin)
    case vitaminB6

    /// Vitamin B12 (Cobalamin)
    case vitaminB12

    /// Folate (Folsäure)
    case folate

    /// Biotin
    case biotin

    /// Pantothenic Acid (Pantothensäure)
    case pantothenicAcid

    // MARK: - Minerals

    /// Calcium
    case calcium

    /// Magnesium
    case magnesium

    /// Iron (Eisen)
    case iron

    /// Zinc (Zink)
    case zinc

    /// Selenium (Selen)
    case selenium

    /// Iodine (Jod)
    case iodine

    /// Copper (Kupfer)
    case copper

    /// Manganese (Mangan)
    case manganese

    /// Chromium (Chrom)
    case chromium

    /// Molybdenum (Molybdän)
    case molybdenum

    // MARK: - Properties

    /// Returns the localized name of the nutrient
    /// Uses the String Catalog (Localizable.xcstrings) for proper localization in de, en, and zh-Hans
    var localizedName: String {
        // Use the nutrient_ prefix to access String Catalog keys
        let key = "nutrient_\(self.rawValue)"
        return NSLocalizedString(key, comment: "")
    }

    /// Returns the unit of measurement for the nutrient
    var unit: String {
        switch self {
        // Vitamins measured in micrograms (μg)
        case .vitaminA, .vitaminD, .vitaminK, .vitaminB12, .folate, .biotin, .iodine, .selenium, .chromium, .molybdenum:
            return "μg"

        // Vitamins and minerals measured in milligrams (mg)
        case .vitaminE, .vitaminC, .vitaminB1, .vitaminB2, .vitaminB3, .vitaminB6, .pantothenicAcid,
             .calcium, .magnesium, .iron, .zinc, .copper, .manganese:
            return "mg"
        }
    }

    /// Returns true if this nutrient is a vitamin (as opposed to a mineral)
    var isVitamin: Bool {
        switch self {
        case .vitaminA, .vitaminD, .vitaminE, .vitaminK, .vitaminC,
             .vitaminB1, .vitaminB2, .vitaminB3, .vitaminB6, .vitaminB12,
             .folate, .biotin, .pantothenicAcid:
            return true
        case .calcium, .magnesium, .iron, .zinc, .selenium,
             .iodine, .copper, .manganese, .chromium, .molybdenum:
            return false
        }
    }
}
