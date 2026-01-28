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
    var localizedName: String {
        switch self {
        // Vitamins
        case .vitaminA:
            return NSLocalizedString("Vitamin A", comment: "Vitamin A")
        case .vitaminD:
            return NSLocalizedString("Vitamin D", comment: "Vitamin D")
        case .vitaminE:
            return NSLocalizedString("Vitamin E", comment: "Vitamin E")
        case .vitaminK:
            return NSLocalizedString("Vitamin K", comment: "Vitamin K")
        case .vitaminC:
            return NSLocalizedString("Vitamin C", comment: "Vitamin C")
        case .vitaminB1:
            return NSLocalizedString("Vitamin B1 (Thiamin)", comment: "Vitamin B1")
        case .vitaminB2:
            return NSLocalizedString("Vitamin B2 (Riboflavin)", comment: "Vitamin B2")
        case .vitaminB3:
            return NSLocalizedString("Vitamin B3 (Niacin)", comment: "Vitamin B3")
        case .vitaminB6:
            return NSLocalizedString("Vitamin B6 (Pyridoxin)", comment: "Vitamin B6")
        case .vitaminB12:
            return NSLocalizedString("Vitamin B12 (Cobalamin)", comment: "Vitamin B12")
        case .folate:
            return NSLocalizedString("Folate", comment: "Folate")
        case .biotin:
            return NSLocalizedString("Biotin", comment: "Biotin")
        case .pantothenicAcid:
            return NSLocalizedString("Pantothenic Acid", comment: "Pantothenic Acid")

        // Minerals
        case .calcium:
            return NSLocalizedString("Calcium", comment: "Calcium")
        case .magnesium:
            return NSLocalizedString("Magnesium", comment: "Magnesium")
        case .iron:
            return NSLocalizedString("Iron", comment: "Iron")
        case .zinc:
            return NSLocalizedString("Zinc", comment: "Zinc")
        case .selenium:
            return NSLocalizedString("Selenium", comment: "Selenium")
        case .iodine:
            return NSLocalizedString("Iodine", comment: "Iodine")
        case .copper:
            return NSLocalizedString("Copper", comment: "Copper")
        case .manganese:
            return NSLocalizedString("Manganese", comment: "Manganese")
        case .chromium:
            return NSLocalizedString("Chromium", comment: "Chromium")
        case .molybdenum:
            return NSLocalizedString("Molybdenum", comment: "Molybdenum")
        }
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
