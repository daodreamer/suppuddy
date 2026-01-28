//
//  UserRepository.swift
//  vitamin_calculator
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Foundation
import SwiftData

/// Repository for managing UserProfile data persistence using SwiftData.
/// Provides CRUD operations for user profiles.
final class UserRepository {

    // MARK: - Properties

    private let modelContext: ModelContext

    // MARK: - Initialization

    /// Creates a new user repository with the specified model context
    /// - Parameter modelContext: The SwiftData model context to use for persistence
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public Methods

    /// Saves a user profile to the database
    /// - Parameter profile: The user profile to save
    /// - Throws: SwiftData errors if save fails
    func save(_ profile: UserProfile) async throws {
        modelContext.insert(profile)
        try modelContext.save()
    }

    /// Updates an existing user profile
    /// - Parameter profile: The user profile to update
    /// - Throws: SwiftData errors if update fails
    func update(_ profile: UserProfile) async throws {
        profile.updatedAt = Date()
        try modelContext.save()
    }

    /// Deletes a user profile from the database
    /// - Parameter profile: The user profile to delete
    /// - Throws: SwiftData errors if delete fails
    func delete(_ profile: UserProfile) async throws {
        modelContext.delete(profile)
        try modelContext.save()
    }

    /// Deletes all user profiles from the database
    /// - Throws: SwiftData errors if delete fails
    func deleteAll() async throws {
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(descriptor)

        for profile in profiles {
            modelContext.delete(profile)
        }

        try modelContext.save()
    }

    /// Retrieves the first user profile (current user)
    /// - Returns: The current user profile, or nil if none exists
    /// - Throws: SwiftData errors if fetch fails
    func getCurrentUser() async throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(descriptor)
        return profiles.first
    }

    /// Retrieves all user profiles from the database
    /// - Returns: Array of all user profiles
    /// - Throws: SwiftData errors if fetch fails
    func getAllUsers() async throws -> [UserProfile] {
        let descriptor = FetchDescriptor<UserProfile>()
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Sprint 6 Extensions

    /// Updates the special needs for the current user
    /// - Parameter needs: The special needs to set
    /// - Throws: SwiftData errors if update fails
    func updateSpecialNeeds(_ needs: SpecialNeeds) async throws {
        guard let user = try await getCurrentUser() else {
            return // No user to update
        }

        user.specialNeeds = needs
        try await update(user)
    }

    /// Marks the onboarding process as complete for the current user
    /// - Throws: SwiftData errors if update fails
    func markOnboardingComplete() async throws {
        guard let user = try await getCurrentUser() else {
            return // No user to update
        }

        user.hasCompletedOnboarding = true
        try await update(user)
    }

    /// Checks if the current user has completed onboarding
    /// - Returns: true if onboarding is complete, false otherwise (or if no user exists)
    /// - Throws: SwiftData errors if fetch fails
    func hasCompletedOnboarding() async throws -> Bool {
        guard let user = try await getCurrentUser() else {
            return false
        }

        return user.hasCompletedOnboarding
    }
}
