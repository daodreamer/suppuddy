//
//  OnboardingServiceTests.swift
//  suppuddyTests
//
//  Created for Sprint 6 - Task 3.4
//

import Foundation
import Testing
import SwiftData
@testable import suppuddy

@Suite("OnboardingService Tests - Sprint 6 Task 3.4")
struct OnboardingServiceTests {

    @Suite("Onboarding State Tests")
    struct OnboardingStateTests {
        @Test("Service should show onboarding when no user exists")
        @MainActor
        func testShouldShowOnboardingNoUser() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let userRepo = UserRepository(modelContext: context)
            let service = OnboardingService(userRepository: userRepo)

            // Act
            let shouldShow = try await service.shouldShowOnboarding()

            // Assert
            #expect(shouldShow == true, "Should show onboarding when no user exists")
        }

        @Test("Service should show onboarding when user has not completed it")
        @MainActor
        func testShouldShowOnboardingNotCompleted() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let userRepo = UserRepository(modelContext: context)
            let service = OnboardingService(userRepository: userRepo)

            // Create user without completing onboarding
            let user = UserProfile(name: "Test", userType: .male)
            user.hasCompletedOnboarding = false
            context.insert(user)
            try context.save()

            // Act
            let shouldShow = try await service.shouldShowOnboarding()

            // Assert
            #expect(shouldShow == true, "Should show onboarding when not completed")
        }

        @Test("Service should not show onboarding when completed")
        @MainActor
        func testShouldNotShowOnboardingCompleted() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let userRepo = UserRepository(modelContext: context)
            let service = OnboardingService(userRepository: userRepo)

            // Create user with completed onboarding
            let user = UserProfile(name: "Test", userType: .male)
            user.hasCompletedOnboarding = true
            context.insert(user)
            try context.save()

            // Act
            let shouldShow = try await service.shouldShowOnboarding()

            // Assert
            #expect(shouldShow == false, "Should not show onboarding when completed")
        }
    }

    @Suite("Complete Onboarding Tests")
    struct CompleteOnboardingTests {
        @Test("Service should create user profile from draft")
        @MainActor
        func testCompleteOnboarding() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let userRepo = UserRepository(modelContext: context)
            let service = OnboardingService(userRepository: userRepo)

            let draft = UserProfileDraft(
                name: "John Doe",
                userType: .male,
                birthDate: Date(),
                specialNeeds: .none
            )

            // Act
            let profile = try await service.completeOnboarding(draft: draft)

            // Assert
            #expect(profile.name == "John Doe")
            #expect(profile.userType == .male)
            #expect(profile.hasCompletedOnboarding == true)
            #expect(profile.specialNeeds == .none)

            // Verify it was saved
            let savedUser = try await userRepo.getCurrentUser()
            #expect(savedUser?.name == "John Doe")
        }

        @Test("Service should set onboarding completed flag")
        @MainActor
        func testOnboardingCompletedFlag() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let userRepo = UserRepository(modelContext: context)
            let service = OnboardingService(userRepository: userRepo)

            let draft = UserProfileDraft(name: "Test", userType: .female)

            // Act
            _ = try await service.completeOnboarding(draft: draft)
            let shouldShow = try await service.shouldShowOnboarding()

            // Assert
            #expect(shouldShow == false, "Should not show onboarding after completion")
        }
    }

    @Suite("Skip Onboarding Tests")
    struct SkipOnboardingTests {
        @Test("Service should create default user when skipping")
        @MainActor
        func testSkipOnboarding() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let userRepo = UserRepository(modelContext: context)
            let service = OnboardingService(userRepository: userRepo)

            // Act
            try await service.skipOnboarding()

            // Assert
            let user = try await userRepo.getCurrentUser()
            #expect(user != nil, "User should be created")
            #expect(user?.hasCompletedOnboarding == true)
            let shouldShow = try await service.shouldShowOnboarding()
            #expect(shouldShow == false, "Should not show onboarding after skip")
        }
    }

    @Suite("UserDefaults Sync Tests")
    struct UserDefaultsSyncTests {
        @Test("Completing onboarding sets UserDefaults flag")
        @MainActor
        func testCompleteOnboardingSetsUserDefaults() async throws {
            // Arrange
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let userRepo = UserRepository(modelContext: context)
            let service = OnboardingService(userRepository: userRepo)

            let draft = UserProfileDraft(name: "Test", userType: .male)

            // Act
            _ = try await service.completeOnboarding(draft: draft)

            // Assert
            #expect(UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") == true)
        }

        @Test("Skipping onboarding sets UserDefaults flag")
        @MainActor
        func testSkipOnboardingSetsUserDefaults() async throws {
            // Arrange
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let userRepo = UserRepository(modelContext: context)
            let service = OnboardingService(userRepository: userRepo)

            // Act
            try await service.skipOnboarding()

            // Assert
            #expect(UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") == true)
        }

        @Test("Resetting onboarding clears UserDefaults flag")
        @MainActor
        func testResetOnboardingClearsUserDefaults() async throws {
            // Arrange
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let userRepo = UserRepository(modelContext: context)
            let service = OnboardingService(userRepository: userRepo)

            let user = UserProfile(name: "Test", userType: .male)
            user.hasCompletedOnboarding = true
            context.insert(user)
            try context.save()

            // Act
            try await service.resetOnboarding()

            // Assert
            #expect(UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") == false)
        }
    }

    @Suite("Reset Onboarding Tests")
    struct ResetOnboardingTests {
        @Test("Service should reset onboarding state")
        @MainActor
        func testResetOnboarding() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let userRepo = UserRepository(modelContext: context)
            let service = OnboardingService(userRepository: userRepo)

            // Create completed user
            let user = UserProfile(name: "Test", userType: .male)
            user.hasCompletedOnboarding = true
            context.insert(user)
            try context.save()

            // Act
            try await service.resetOnboarding()

            // Assert
            let shouldShow = try await service.shouldShowOnboarding()
            #expect(shouldShow == true, "Should show onboarding after reset")
        }

        @Test("Service should handle reset with no user gracefully")
        @MainActor
        func testResetOnboardingNoUser() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let userRepo = UserRepository(modelContext: context)
            let service = OnboardingService(userRepository: userRepo)

            // Act & Assert - should not throw
            try await service.resetOnboarding()
        }
    }
}
