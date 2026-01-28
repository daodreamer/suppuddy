//
//  SupplementFormViewModel.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Observation
import SwiftData

/// ViewModel for the supplement creation/edit form.
/// Handles form state, validation, and saving.
@MainActor
@Observable
final class SupplementFormViewModel {

    // MARK: - Form Fields

    /// Supplement name
    var name: String = ""

    /// Brand name (optional)
    var brand: String = ""

    /// Serving size description
    var servingSize: String = ""

    /// Number of servings per day
    var servingsPerDay: Int = 1

    /// Additional notes
    var notes: String = ""

    /// List of nutrients in the supplement
    var nutrients: [Nutrient] = []

    /// Whether the supplement is currently active
    var isActive: Bool = true

    /// Image data (optional)
    var imageData: Data?

    // MARK: - State

    /// Whether we're editing an existing supplement
    var isEditing: Bool = false

    /// Current validation errors
    var validationErrors: [SupplementValidationError] = []

    /// Error message for display
    var errorMessage: String?

    /// The supplement being edited (if any)
    private var editingSupplement: Supplement?

    /// Supplement service for validation
    private let service = SupplementService()

    // MARK: - Initialization

    /// Creates a new form for creating a supplement
    init() {
        self.isEditing = false
    }

    /// Creates a form for editing an existing supplement
    /// - Parameter supplement: The supplement to edit
    init(supplement: Supplement) {
        self.editingSupplement = supplement
        self.isEditing = true

        // Populate form fields from supplement
        self.name = supplement.name
        self.brand = supplement.brand ?? ""
        self.servingSize = supplement.servingSize
        self.servingsPerDay = supplement.servingsPerDay
        self.notes = supplement.notes ?? ""
        self.nutrients = supplement.nutrients
        self.isActive = supplement.isActive
        self.imageData = supplement.imageData
    }

    // MARK: - Validation

    /// Validates the form and returns whether it's valid
    /// - Returns: true if the form is valid
    func validate() -> Bool {
        validationErrors = []

        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append(.emptyName)
        }

        if servingSize.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors.append(.emptyServingSize)
        }

        if servingsPerDay <= 0 {
            validationErrors.append(.invalidServingsPerDay)
        }

        return validationErrors.isEmpty
    }

    // MARK: - Nutrient Management

    /// Adds a nutrient to the form
    /// - Parameters:
    ///   - type: The type of nutrient
    ///   - amount: The amount per serving
    func addNutrient(type: NutrientType, amount: Double) {
        nutrients.append(Nutrient(type: type, amount: amount))
    }

    /// Removes a nutrient at the specified index
    /// - Parameter index: The index of the nutrient to remove
    func removeNutrient(at index: Int) {
        guard index >= 0 && index < nutrients.count else { return }
        nutrients.remove(at: index)
    }

    /// Updates the amount of a nutrient at the specified index
    /// - Parameters:
    ///   - index: The index of the nutrient
    ///   - amount: The new amount
    func updateNutrientAmount(at index: Int, amount: Double) {
        guard index >= 0 && index < nutrients.count else { return }
        let oldNutrient = nutrients[index]
        nutrients[index] = Nutrient(type: oldNutrient.type, amount: amount)
    }

    // MARK: - Save

    /// Saves the supplement (creates new or updates existing)
    /// - Parameter repository: The repository to save to
    /// - Returns: true if save was successful
    func save(using repository: SupplementRepository) async -> Bool {
        guard validate() else {
            return false
        }

        do {
            if isEditing, let supplement = editingSupplement {
                // Update existing supplement
                supplement.name = name
                supplement.brand = brand.isEmpty ? nil : brand
                supplement.servingSize = servingSize
                supplement.servingsPerDay = servingsPerDay
                supplement.notes = notes.isEmpty ? nil : notes
                supplement.nutrients = nutrients
                supplement.isActive = isActive
                supplement.imageData = imageData

                try await repository.update(supplement)
            } else {
                // Create new supplement
                let supplement = Supplement(
                    name: name,
                    brand: brand.isEmpty ? nil : brand,
                    servingSize: servingSize,
                    servingsPerDay: servingsPerDay,
                    nutrients: nutrients,
                    notes: notes.isEmpty ? nil : notes,
                    imageData: imageData,
                    isActive: isActive
                )
                try await repository.save(supplement)
            }
            return true
        } catch {
            errorMessage = "Failed to save supplement: \(error.localizedDescription)"
            return false
        }
    }
}
