//
//  UserProfileViewModel.swift
//  vitamin_calculator
//
//  Created by Claude Code on 28.01.26.
//

import Foundation
import SwiftData
import Observation

/// ViewModel for managing user profile data and personalized recommendations.
/// Handles loading, updating, and saving user profile information.
@MainActor
@Observable
final class UserProfileViewModel {

    // MARK: - Published Properties

    /// The current user profile (nil if no profile exists)
    var userProfile: UserProfile?

    /// Editable name field
    var name: String = ""

    /// Editable user type field
    var userType: UserType = .male

    /// Editable birth date field
    var birthDate: Date?

    /// Editable special needs field
    var specialNeeds: SpecialNeeds = .none

    /// Loading state indicator
    var isLoading: Bool = false

    /// Error message if operations fail
    var errorMessage: String?

    /// Flag indicating if changes have been saved
    var isSaved: Bool = false

    /// Current user's personalized recommendations
    var recommendations: [NutrientType: DailyRecommendation] = [:]

    // MARK: - Private Properties

    private let userRepository: UserRepository
    private let recommendationService: RecommendationService

    // MARK: - Initialization

    /// Creates a new user profile view model
    /// - Parameters:
    ///   - userRepository: Repository for user data persistence
    ///   - recommendationService: Service for retrieving recommendations
    init(userRepository: UserRepository, recommendationService: RecommendationService) {
        self.userRepository = userRepository
        self.recommendationService = recommendationService
    }

    // MARK: - Public Methods

    /// Loads the current user profile from the repository.
    /// If a profile exists, populates all editable fields and updates recommendations.
    /// If no profile exists, resets fields to default values.
    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            if let profile = try await userRepository.getCurrentUser() {
                // Profile exists - populate fields
                userProfile = profile
                name = profile.name
                userType = profile.userType
                birthDate = profile.birthDate
                specialNeeds = profile.specialNeeds ?? .none

                // Update recommendations based on loaded profile
                updateRecommendations()
            } else {
                // No profile exists - reset to defaults
                userProfile = nil
                name = ""
                userType = .male
                birthDate = nil
                specialNeeds = .none
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Saves the current profile changes.
    /// Validates input, creates a new profile or updates existing one, and refreshes recommendations.
    /// Sets isSaved to true on success, or populates errorMessage on failure.
    func saveProfile() async {
        isLoading = true
        errorMessage = nil
        isSaved = false

        // Validate required fields
        guard !name.isEmpty else {
            errorMessage = "名称不能为空"
            isLoading = false
            return
        }

        do {
            if let existingProfile = userProfile {
                // Update existing profile with current field values
                existingProfile.name = name
                existingProfile.userType = userType
                existingProfile.birthDate = birthDate
                existingProfile.specialNeeds = specialNeeds

                try await userRepository.update(existingProfile)
                userProfile = existingProfile
            } else {
                // Create new profile from current field values
                let newProfile = UserProfile(name: name, userType: userType)
                newProfile.birthDate = birthDate
                newProfile.specialNeeds = specialNeeds

                try await userRepository.save(newProfile)
                userProfile = newProfile
            }

            isSaved = true
            errorMessage = nil

            // Refresh recommendations with updated profile
            updateRecommendations()
        } catch {
            errorMessage = error.localizedDescription
            isSaved = false
        }

        isLoading = false
    }

    /// Updates recommendations based on current user profile.
    /// Fetches personalized recommendations considering user type and special needs.
    /// Clears recommendations if no profile is loaded.
    func updateRecommendations() {
        guard let profile = userProfile else {
            recommendations = [:]
            return
        }

        // Get all personalized recommendations for this user
        let allRecommendations = recommendationService.getAllRecommendations(for: profile)

        // Convert array to dictionary for efficient lookup
        recommendations = Dictionary(
            uniqueKeysWithValues: allRecommendations.map { ($0.nutrientType, $0) }
        )
    }
}
