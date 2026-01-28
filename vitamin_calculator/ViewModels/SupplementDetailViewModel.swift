//
//  SupplementDetailViewModel.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Observation
import SwiftData

/// ViewModel for displaying supplement details.
/// Provides computed properties for nutrient information and recommendations.
@MainActor
@Observable
final class SupplementDetailViewModel {

    // MARK: - Properties

    /// The supplement being displayed
    let supplement: Supplement

    /// Error message for display
    var errorMessage: String?

    // MARK: - Initialization

    /// Creates a new SupplementDetailViewModel
    /// - Parameter supplement: The supplement to display
    init(supplement: Supplement) {
        self.supplement = supplement
    }

    // MARK: - Computed Properties

    /// Dictionary of daily nutrient amounts
    var dailyNutrientAmounts: [NutrientType: Double] {
        supplement.allNutrientsDailyAmounts()
    }

    // MARK: - Public Methods

    /// Calculates the percentage of daily recommendation for a nutrient
    /// - Parameters:
    ///   - nutrientType: The type of nutrient
    ///   - userType: The user's demographic type
    /// - Returns: Percentage of daily recommendation (0-100+)
    func percentageOfRecommendation(for nutrientType: NutrientType, userType: UserType) -> Double {
        supplement.percentageOfRecommendation(for: nutrientType, userType: userType)
    }

    /// Determines the status of a nutrient based on DGE recommendations
    /// - Parameters:
    ///   - nutrientType: The type of nutrient
    ///   - userType: The user's demographic type
    /// - Returns: The nutrient status
    func nutrientStatus(for nutrientType: NutrientType, userType: UserType) -> NutrientStatus {
        supplement.nutrientStatus(for: nutrientType, userType: userType)
    }

    /// Toggles the active state of the supplement
    /// - Parameter repository: The repository to save changes
    func toggleActive(using repository: SupplementRepository) async {
        supplement.isActive.toggle()
        do {
            try await repository.update(supplement)
        } catch {
            errorMessage = "Failed to update supplement: \(error.localizedDescription)"
            supplement.isActive.toggle() // Revert on failure
        }
    }
}
