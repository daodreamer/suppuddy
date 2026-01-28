//
//  Supplement.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import SwiftData

/// Represents a dietary supplement product with its nutritional content.
/// Used to track user's supplement intake and calculate total nutrient consumption.
@Model
final class Supplement {
    // MARK: - Stored Properties

    /// The name of the supplement product
    var name: String

    /// The brand name of the supplement (optional)
    var brand: String?

    /// The serving size description (e.g., "1 tablet", "2 capsules")
    var servingSize: String

    /// Number of servings taken per day
    var servingsPerDay: Int

    /// Encoded nutrients data for SwiftData persistence
    @Attribute(.transformable(by: "NSSecureUnarchiveFromDataTransformer"))
    private var nutrientsData: Data?

    /// Optional notes about the supplement
    var notes: String?

    /// Optional image data for the supplement product
    var imageData: Data?

    /// Whether the supplement is currently being taken
    var isActive: Bool

    /// Timestamp when the supplement was created
    var createdAt: Date

    /// Timestamp when the supplement was last updated
    var updatedAt: Date

    /// Intake records associated with this supplement
    /// When supplement is deleted, records are preserved with nullified reference
    @Relationship(deleteRule: .nullify, inverse: \IntakeRecord.supplement)
    var intakeRecords: [IntakeRecord] = []

    // MARK: - Computed Properties

    /// The list of nutrients contained in this supplement per serving
    var nutrients: [Nutrient] {
        get {
            guard let data = nutrientsData,
                  let decoded = try? JSONDecoder().decode([Nutrient].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            nutrientsData = try? JSONEncoder().encode(newValue)
        }
    }

    // MARK: - Initialization

    /// Creates a new supplement
    /// - Parameters:
    ///   - name: The name of the supplement
    ///   - brand: The brand name (optional)
    ///   - servingSize: The serving size description
    ///   - servingsPerDay: Number of servings per day (default: 1)
    ///   - nutrients: List of nutrients per serving (default: empty)
    ///   - notes: Optional notes about the supplement
    ///   - imageData: Optional image data
    ///   - isActive: Whether currently being taken (default: true)
    init(
        name: String,
        brand: String? = nil,
        servingSize: String,
        servingsPerDay: Int = 1,
        nutrients: [Nutrient] = [],
        notes: String? = nil,
        imageData: Data? = nil,
        isActive: Bool = true
    ) {
        self.name = name
        self.brand = brand
        self.servingSize = servingSize
        self.servingsPerDay = servingsPerDay
        self.notes = notes
        self.imageData = imageData
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()

        // Set nutrients through the computed property setter
        self.nutrients = nutrients
    }

    // MARK: - Public Methods

    /// Calculates the total daily amount of a specific nutrient
    /// - Parameter nutrientType: The type of nutrient to calculate
    /// - Returns: Total daily amount (amount per serving × servings per day)
    func totalDailyAmount(for nutrientType: NutrientType) -> Double {
        guard let nutrient = nutrients.first(where: { $0.type == nutrientType }) else {
            return 0
        }
        return nutrient.amount * Double(servingsPerDay)
    }

    /// Calculates the percentage of daily recommended intake this supplement provides
    /// - Parameters:
    ///   - nutrientType: The type of nutrient to calculate
    ///   - userType: The user's demographic type for recommendation lookup
    /// - Returns: Percentage of daily recommendation (0-100+)
    func percentageOfRecommendation(for nutrientType: NutrientType, userType: UserType) -> Double {
        let dailyAmount = totalDailyAmount(for: nutrientType)
        guard dailyAmount > 0 else { return 0 }

        guard let recommendation = DGERecommendations.getRecommendation(
            for: nutrientType,
            userType: userType
        ) else {
            return 0
        }

        return (dailyAmount / recommendation.recommendedAmount) * 100
    }

    /// Determines the intake status of a nutrient based on DGE recommendations
    /// - Parameters:
    ///   - nutrientType: The type of nutrient to evaluate
    ///   - userType: The user's demographic type for recommendation lookup
    /// - Returns: The nutrient status (none, insufficient, normal, or excessive)
    func nutrientStatus(for nutrientType: NutrientType, userType: UserType) -> NutrientStatus {
        let dailyAmount = totalDailyAmount(for: nutrientType)
        guard dailyAmount > 0 else { return .none }

        guard let recommendation = DGERecommendations.getRecommendation(
            for: nutrientType,
            userType: userType
        ) else {
            return .none
        }

        let percentage = (dailyAmount / recommendation.recommendedAmount) * 100

        // Check if exceeds upper limit (if defined)
        if let upperLimit = recommendation.upperLimit, dailyAmount > upperLimit {
            return .excessive
        }

        // Check if below 80% of recommended
        if percentage < 80 {
            return .insufficient
        }

        return .normal
    }

    /// Returns a dictionary of all nutrients with their daily amounts
    /// - Returns: Dictionary mapping nutrient types to their total daily amounts
    func allNutrientsDailyAmounts() -> [NutrientType: Double] {
        var result: [NutrientType: Double] = [:]
        for nutrient in nutrients {
            result[nutrient.type] = nutrient.amount * Double(servingsPerDay)
        }
        return result
    }
}
