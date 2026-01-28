//
//  OnboardingService.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 3.4
//

import Foundation
import SwiftData

/// Service for managing the onboarding flow
@MainActor
final class OnboardingService {

    // MARK: - Properties

    private let userRepository: UserRepository

    // MARK: - Initialization

    /// Creates a new onboarding service
    /// - Parameter userRepository: Repository for user data
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    // MARK: - Public Methods

    /// Checks if the onboarding flow should be shown
    /// - Returns: true if onboarding should be shown (no user or onboarding not completed)
    /// - Throws: Repository errors
    func shouldShowOnboarding() async throws -> Bool {
        guard let user = try await userRepository.getCurrentUser() else {
            // No user exists, show onboarding
            return true
        }

        // Check if onboarding is completed
        return !user.hasCompletedOnboarding
    }

    /// Completes the onboarding flow and creates a user profile
    /// - Parameter draft: The user profile draft from onboarding
    /// - Returns: The created user profile
    /// - Throws: Repository errors
    func completeOnboarding(draft: UserProfileDraft) async throws -> UserProfile {
        // Create user profile from draft
        let profile = UserProfile(name: draft.name, userType: draft.userType)
        profile.birthDate = draft.birthDate
        profile.specialNeeds = draft.specialNeeds
        profile.hasCompletedOnboarding = true

        // Save to repository
        try await userRepository.save(profile)

        return profile
    }

    /// Skips the onboarding flow
    /// Creates a default user profile with onboarding marked as completed
    /// - Throws: Repository errors
    func skipOnboarding() async throws {
        let profile = UserProfile(name: "User", userType: .male)
        profile.hasCompletedOnboarding = true

        try await userRepository.save(profile)
    }

    /// Resets the onboarding state (for testing/debugging)
    /// Marks the current user's onboarding as incomplete
    /// - Throws: Repository errors
    func resetOnboarding() async throws {
        guard let user = try await userRepository.getCurrentUser() else {
            return // No user to reset
        }

        user.hasCompletedOnboarding = false
        try await userRepository.update(user)
    }
}
