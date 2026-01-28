//
//  RecommendationService.swift
//  vitamin_calculator
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Foundation

/// Service for retrieving nutrient recommendations for users.
/// Acts as a business logic layer between the UI and the DGE data.
final class RecommendationService {

    // MARK: - Initialization

    /// Creates a new recommendation service
    init() {}

    // MARK: - Public Methods

    /// Retrieves the daily recommendation for a specific nutrient and user
    /// - Parameters:
    ///   - nutrient: The nutrient type to get recommendations for
    ///   - user: The user profile to get recommendations for
    /// - Returns: A DailyRecommendation if available, considering special needs
    func getRecommendation(for nutrient: NutrientType, user: UserProfile) -> DailyRecommendation? {
        // Check for special needs recommendations first
        if let specialNeeds = user.specialNeeds, specialNeeds != .none {
            // Try to get special recommendation
            let specialRec: DailyRecommendation?

            switch specialNeeds {
            case .pregnant:
                specialRec = DGERecommendations.getPregnancyRecommendation(for: nutrient)
            case .breastfeeding:
                specialRec = DGERecommendations.getBreastfeedingRecommendation(for: nutrient)
            case .pregnantAndBreastfeeding:
                // For combined needs, use the higher recommendation between pregnancy and breastfeeding
                let pregnancyRec = DGERecommendations.getPregnancyRecommendation(for: nutrient)
                let breastfeedingRec = DGERecommendations.getBreastfeedingRecommendation(for: nutrient)

                if let pRec = pregnancyRec, let bRec = breastfeedingRec {
                    specialRec = pRec.recommendedAmount > bRec.recommendedAmount ? pRec : bRec
                } else {
                    specialRec = pregnancyRec ?? breastfeedingRec
                }
            case .none:
                specialRec = nil
            }

            // If special recommendation exists, return it
            if let specialRec = specialRec {
                return specialRec
            }
        }

        // Fall back to standard recommendation based on user type
        return DGERecommendations.getRecommendation(for: nutrient, userType: user.userType)
    }

    /// Retrieves all daily recommendations for a user
    /// - Parameter user: The user profile to get recommendations for
    /// - Returns: Array of all nutrient recommendations for this user, considering special needs
    func getAllRecommendations(for user: UserProfile) -> [DailyRecommendation] {
        return NutrientType.allCases.compactMap { nutrient in
            getRecommendation(for: nutrient, user: user)
        }
    }

    // MARK: - Special Needs Helpers (Sprint 6 - Task 3.1)

    /// Checks if a special recommendation exists for a nutrient and special need
    /// - Parameters:
    ///   - nutrient: The nutrient type
    ///   - specialNeeds: The special needs type
    /// - Returns: true if a special recommendation exists
    func hasSpecialRecommendation(for nutrient: NutrientType, specialNeeds: SpecialNeeds) -> Bool {
        switch specialNeeds {
        case .none:
            return false
        case .pregnant:
            return DGERecommendations.getPregnancyRecommendation(for: nutrient) != nil
        case .breastfeeding:
            return DGERecommendations.getBreastfeedingRecommendation(for: nutrient) != nil
        case .pregnantAndBreastfeeding:
            return DGERecommendations.getPregnancyRecommendation(for: nutrient) != nil ||
                   DGERecommendations.getBreastfeedingRecommendation(for: nutrient) != nil
        }
    }
}
