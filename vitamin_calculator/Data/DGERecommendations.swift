//
//  DGERecommendations.swift
//  vitamin_calculator
//
//  Created by Jiongdao Wang on 25.01.26.
//
//  Data source: Deutsche Gesellschaft für Ernährung (DGE)
//  https://www.dge.de/wissenschaft/referenzwerte/
//

import Foundation

/// Provides nutrient recommendations based on German DGE (Deutsche Gesellschaft für Ernährung) standards.
/// Contains reference values for daily nutrient intake for different demographic groups.
struct DGERecommendations {

    // MARK: - Public Methods

    /// Retrieves the daily recommendation for a specific nutrient and user type
    /// - Parameters:
    ///   - nutrient: The nutrient type
    ///   - userType: The user demographic type
    /// - Returns: A DailyRecommendation if available, nil otherwise
    static func getRecommendation(for nutrient: NutrientType, userType: UserType) -> DailyRecommendation? {
        switch userType {
        case .male:
            return getAdultMaleRecommendation(for: nutrient)
        case .female:
            return getAdultFemaleRecommendation(for: nutrient)
        case .child(let age):
            return getChildRecommendation(for: nutrient, age: age)
        }
    }

    /// Retrieves all daily recommendations for a specific user type
    /// - Parameter userType: The user demographic type
    /// - Returns: Array of all nutrient recommendations for this user type
    static func getAllRecommendations(for userType: UserType) -> [DailyRecommendation] {
        return NutrientType.allCases.compactMap { nutrient in
            getRecommendation(for: nutrient, userType: userType)
        }
    }

    // MARK: - Special Needs Recommendations (Sprint 6 - Task 3.1)

    /// Retrieves the pregnancy recommendation for a specific nutrient
    /// - Parameter nutrient: The nutrient type
    /// - Returns: A DailyRecommendation for pregnancy, or nil if no special recommendation exists
    static func getPregnancyRecommendation(for nutrient: NutrientType) -> DailyRecommendation? {
        switch nutrient {
        // Nutrients with specific pregnancy recommendations
        case .folate:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 550, upperLimit: 1000, userType: .female)
        case .iron:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 30, upperLimit: 45, userType: .female)
        case .iodine:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 230, upperLimit: 500, userType: .female)
        case .vitaminD:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 20, upperLimit: 100, userType: .female)
        default:
            return nil // No special pregnancy recommendation for this nutrient
        }
    }

    /// Retrieves the breastfeeding recommendation for a specific nutrient
    /// - Parameter nutrient: The nutrient type
    /// - Returns: A DailyRecommendation for breastfeeding, or nil if no special recommendation exists
    static func getBreastfeedingRecommendation(for nutrient: NutrientType) -> DailyRecommendation? {
        switch nutrient {
        // Nutrients with specific breastfeeding recommendations
        case .folate:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 450, upperLimit: 1000, userType: .female)
        case .iron:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 20, upperLimit: 45, userType: .female)
        case .iodine:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 260, upperLimit: 500, userType: .female)
        case .vitaminD:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 20, upperLimit: 100, userType: .female)
        default:
            return nil // No special breastfeeding recommendation for this nutrient
        }
    }

    // MARK: - Private Helper Methods

    private static func getAdultMaleRecommendation(for nutrient: NutrientType) -> DailyRecommendation {
        switch nutrient {
        // Vitamins (values in mg or μg)
        case .vitaminA:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 850, upperLimit: 3000, userType: .male)
        case .vitaminD:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 20, upperLimit: 100, userType: .male)
        case .vitaminE:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 14, upperLimit: 300, userType: .male)
        case .vitaminK:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 70, upperLimit: nil, userType: .male)
        case .vitaminC:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 110, upperLimit: 2000, userType: .male)
        case .vitaminB1:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 1.2, upperLimit: nil, userType: .male)
        case .vitaminB2:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 1.4, upperLimit: nil, userType: .male)
        case .vitaminB3:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 16, upperLimit: 35, userType: .male)
        case .vitaminB6:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 1.6, upperLimit: 25, userType: .male)
        case .vitaminB12:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 4.0, upperLimit: nil, userType: .male)
        case .folate:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 300, upperLimit: 1000, userType: .male)
        case .biotin:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 40, upperLimit: nil, userType: .male)
        case .pantothenicAcid:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 6, upperLimit: nil, userType: .male)

        // Minerals (values in mg or μg)
        case .calcium:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 1000, upperLimit: 2500, userType: .male)
        case .magnesium:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 350, upperLimit: 250, userType: .male)
        case .iron:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 10, upperLimit: 45, userType: .male)
        case .zinc:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 14, upperLimit: 40, userType: .male)
        case .selenium:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 70, upperLimit: 300, userType: .male)
        case .iodine:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 200, upperLimit: 500, userType: .male)
        case .copper:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 1.5, upperLimit: 5, userType: .male)
        case .manganese:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 2.5, upperLimit: 11, userType: .male)
        case .chromium:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 35, upperLimit: nil, userType: .male)
        case .molybdenum:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 50, upperLimit: 600, userType: .male)
        }
    }

    private static func getAdultFemaleRecommendation(for nutrient: NutrientType) -> DailyRecommendation {
        switch nutrient {
        // Vitamins
        case .vitaminA:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 700, upperLimit: 3000, userType: .female)
        case .vitaminD:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 20, upperLimit: 100, userType: .female)
        case .vitaminE:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 12, upperLimit: 300, userType: .female)
        case .vitaminK:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 60, upperLimit: nil, userType: .female)
        case .vitaminC:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 95, upperLimit: 2000, userType: .female)
        case .vitaminB1:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 1.0, upperLimit: nil, userType: .female)
        case .vitaminB2:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 1.1, upperLimit: nil, userType: .female)
        case .vitaminB3:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 13, upperLimit: 35, userType: .female)
        case .vitaminB6:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 1.4, upperLimit: 25, userType: .female)
        case .vitaminB12:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 4.0, upperLimit: nil, userType: .female)
        case .folate:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 300, upperLimit: 1000, userType: .female)
        case .biotin:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 40, upperLimit: nil, userType: .female)
        case .pantothenicAcid:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 6, upperLimit: nil, userType: .female)

        // Minerals
        case .calcium:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 1000, upperLimit: 2500, userType: .female)
        case .magnesium:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 300, upperLimit: 250, userType: .female)
        case .iron:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 15, upperLimit: 45, userType: .female)
        case .zinc:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 10, upperLimit: 40, userType: .female)
        case .selenium:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 60, upperLimit: 300, userType: .female)
        case .iodine:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 200, upperLimit: 500, userType: .female)
        case .copper:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 1.25, upperLimit: 5, userType: .female)
        case .manganese:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 2.5, upperLimit: 11, userType: .female)
        case .chromium:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 30, upperLimit: nil, userType: .female)
        case .molybdenum:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 50, upperLimit: 600, userType: .female)
        }
    }

    private static func getChildRecommendation(for nutrient: NutrientType, age: Int) -> DailyRecommendation {
        let userType = UserType.child(age: age)

        // Age brackets: 1-3, 4-6, 7-9, 10-12, 13-14, 15-18
        switch nutrient {
        // Vitamins
        case .vitaminA:
            let amount = getChildValue(age: age, values: [300, 350, 450, 600, 800, 850])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 1500, userType: userType)
        case .vitaminD:
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: 20, upperLimit: 50, userType: userType)
        case .vitaminE:
            let amount = getChildValue(age: age, values: [6, 8, 10, 13, 14, 15])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 200, userType: userType)
        case .vitaminK:
            let amount = getChildValue(age: age, values: [15, 20, 30, 40, 50, 60])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: nil, userType: userType)
        case .vitaminC:
            let amount = getChildValue(age: age, values: [20, 30, 45, 65, 85, 90])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 1000, userType: userType)
        case .vitaminB1:
            let amount = getChildValue(age: age, values: [0.6, 0.7, 0.9, 1.0, 1.2, 1.3])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: nil, userType: userType)
        case .vitaminB2:
            let amount = getChildValue(age: age, values: [0.7, 0.8, 1.0, 1.1, 1.3, 1.4])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: nil, userType: userType)
        case .vitaminB3:
            let amount = getChildValue(age: age, values: [8, 9, 11, 13, 15, 16])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 20, userType: userType)
        case .vitaminB6:
            let amount = getChildValue(age: age, values: [0.6, 0.7, 1.0, 1.2, 1.4, 1.6])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 15, userType: userType)
        case .vitaminB12:
            let amount = getChildValue(age: age, values: [1.5, 2.0, 2.5, 3.5, 4.0, 4.0])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: nil, userType: userType)
        case .folate:
            let amount = getChildValue(age: age, values: [120, 140, 180, 240, 300, 300])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 400, userType: userType)
        case .biotin:
            let amount = getChildValue(age: age, values: [10, 15, 20, 25, 35, 40])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: nil, userType: userType)
        case .pantothenicAcid:
            let amount = getChildValue(age: age, values: [3, 4, 4, 5, 6, 6])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: nil, userType: userType)

        // Minerals
        case .calcium:
            let amount = getChildValue(age: age, values: [600, 750, 900, 1100, 1200, 1200])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 2000, userType: userType)
        case .magnesium:
            let amount = getChildValue(age: age, values: [80, 120, 170, 230, 310, 350])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 200, userType: userType)
        case .iron:
            let amount = getChildValue(age: age, values: [8, 8, 10, 12, 15, 15])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 40, userType: userType)
        case .zinc:
            let amount = getChildValue(age: age, values: [3, 5, 7, 9, 12, 14])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 25, userType: userType)
        case .selenium:
            let amount = getChildValue(age: age, values: [15, 20, 30, 45, 60, 70])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 200, userType: userType)
        case .iodine:
            let amount = getChildValue(age: age, values: [100, 120, 140, 180, 200, 200])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 400, userType: userType)
        case .copper:
            let amount = getChildValue(age: age, values: [0.5, 0.6, 0.8, 1.0, 1.2, 1.5])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 3, userType: userType)
        case .manganese:
            let amount = getChildValue(age: age, values: [1.0, 1.5, 2.0, 2.5, 2.5, 2.5])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 6, userType: userType)
        case .chromium:
            let amount = getChildValue(age: age, values: [20, 25, 30, 35, 35, 35])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: nil, userType: userType)
        case .molybdenum:
            let amount = getChildValue(age: age, values: [25, 30, 40, 50, 50, 50])
            return DailyRecommendation(nutrientType: nutrient, recommendedAmount: amount, upperLimit: 400, userType: userType)
        }
    }

    /// Helper method to get age-appropriate values for children
    /// - Parameters:
    ///   - age: Child's age
    ///   - values: Array of 6 values for age brackets: [1-3, 4-6, 7-9, 10-12, 13-14, 15-18]
    /// - Returns: The appropriate value for the age
    private static func getChildValue(age: Int, values: [Double]) -> Double {
        guard values.count == 6 else { return values.first ?? 0 }

        switch age {
        case 0...3:
            return values[0]
        case 4...6:
            return values[1]
        case 7...9:
            return values[2]
        case 10...12:
            return values[3]
        case 13...14:
            return values[4]
        case 15...18:
            return values[5]
        default:
            return values[5] // Default to oldest age bracket
        }
    }
}
