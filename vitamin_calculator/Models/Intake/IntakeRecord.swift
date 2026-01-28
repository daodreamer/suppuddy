//
//  IntakeRecord.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import SwiftData

/// Represents a record of supplement intake at a specific time.
/// Stores a snapshot of nutrient data to preserve history even if the supplement is modified or deleted.
@Model
final class IntakeRecord {
    // MARK: - Stored Properties

    /// Reference to the original supplement (may become nil if supplement is deleted)
    var supplement: Supplement?

    /// Snapshot of supplement name at time of recording (preserved even if supplement is deleted)
    var supplementName: String

    /// The date when the supplement was taken
    /// Sprint 7 Phase 1: Added indexing hint for better query performance
    @Attribute(.spotlight)
    var date: Date

    /// The time of day when the supplement was taken
    var timeOfDay: TimeOfDay

    /// Number of servings taken
    var servingsTaken: Int

    /// Encoded nutrients data for SwiftData persistence (snapshot of nutrients at time of recording)
    @Attribute(.transformable(by: "NSSecureUnarchiveFromDataTransformer"))
    private var nutrientsData: Data?

    /// Optional notes about this intake record
    var notes: String?

    /// Timestamp when the record was created
    var createdAt: Date

    // MARK: - Computed Properties

    /// The list of nutrients recorded for this intake (snapshot from the time of recording)
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

    /// Creates a new intake record
    /// - Parameters:
    ///   - supplement: Optional reference to the supplement (for tracking)
    ///   - supplementName: Name of the supplement (snapshot)
    ///   - date: Date when the supplement was taken
    ///   - timeOfDay: Time of day when taken
    ///   - servingsTaken: Number of servings taken
    ///   - nutrients: List of nutrients per serving (snapshot)
    ///   - notes: Optional notes about this intake
    init(
        supplement: Supplement? = nil,
        supplementName: String,
        date: Date,
        timeOfDay: TimeOfDay,
        servingsTaken: Int,
        nutrients: [Nutrient],
        notes: String? = nil
    ) {
        self.supplement = supplement
        self.supplementName = supplementName
        self.date = date
        self.timeOfDay = timeOfDay
        self.servingsTaken = servingsTaken
        self.notes = notes
        self.createdAt = Date()

        // Set nutrients through the computed property setter
        self.nutrients = nutrients
    }

    // MARK: - Public Methods

    /// Calculates the total amount of a specific nutrient for this intake
    /// - Parameter nutrientType: The type of nutrient to calculate
    /// - Returns: Total amount (amount per serving × servings taken)
    func totalAmount(for nutrientType: NutrientType) -> Double {
        guard let nutrient = nutrients.first(where: { $0.type == nutrientType }) else {
            return 0
        }
        return nutrient.amount * Double(servingsTaken)
    }

    /// Returns a dictionary of all nutrients with their total amounts for this intake
    /// - Returns: Dictionary mapping nutrient types to their total amounts
    func allNutrientsTotalAmounts() -> [NutrientType: Double] {
        var result: [NutrientType: Double] = [:]
        for nutrient in nutrients {
            result[nutrient.type] = nutrient.amount * Double(servingsTaken)
        }
        return result
    }

    /// Checks if this record is from the same day as the given date
    /// - Parameter otherDate: The date to compare with
    /// - Returns: True if both dates are on the same calendar day
    func isSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: otherDate)
    }
}
