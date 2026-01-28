//
//  UserRepositoryTests.swift
//  vitamin_calculatorTests
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Foundation
import SwiftData
import Testing
@testable import vitamin_calculator

@Suite("UserRepository Tests")
struct UserRepositoryTests {

    @Suite("Save Tests")
    struct SaveTests {
        @Test("Repository should save user profile")
        func testSaveUser() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let profile = UserProfile(name: "Test User", userType: .male)

            // Act
            try await repository.save(profile)

            // Assert
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try context.fetch(descriptor)
            #expect(profiles.count == 1)
            #expect(profiles.first?.name == "Test User")
        }

        @Test("Repository should save multiple users")
        func testSaveMultipleUsers() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let user1 = UserProfile(name: "User 1", userType: .male)
            let user2 = UserProfile(name: "User 2", userType: .female)

            // Act
            try await repository.save(user1)
            try await repository.save(user2)

            // Assert
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try context.fetch(descriptor)
            #expect(profiles.count == 2)
        }
    }

    @Suite("Fetch Tests")
    struct FetchTests {
        @Test("Repository should fetch current user")
        func testGetCurrentUser() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let profile = UserProfile(name: "Current User", userType: .male)
            try await repository.save(profile)

            // Act
            let fetchedUser = try await repository.getCurrentUser()

            // Assert
            #expect(fetchedUser != nil)
            #expect(fetchedUser?.name == "Current User")
        }

        @Test("Repository should return nil when no users exist")
        func testGetCurrentUserWhenEmpty() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            // Act
            let fetchedUser = try await repository.getCurrentUser()

            // Assert
            #expect(fetchedUser == nil)
        }

        @Test("Repository should fetch all users")
        func testGetAllUsers() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let user1 = UserProfile(name: "User 1", userType: .male)
            let user2 = UserProfile(name: "User 2", userType: .female)
            try await repository.save(user1)
            try await repository.save(user2)

            // Act
            let allUsers = try await repository.getAllUsers()

            // Assert
            #expect(allUsers.count == 2)
        }
    }

    @Suite("Update Tests")
    struct UpdateTests {
        @Test("Repository should update user profile")
        func testUpdateUser() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let profile = UserProfile(name: "Original", userType: .male)
            try await repository.save(profile)

            // Act
            profile.name = "Updated"
            profile.userType = .female
            try await repository.update(profile)

            // Assert
            let fetchedUser = try await repository.getCurrentUser()
            #expect(fetchedUser?.name == "Updated")
            #expect(fetchedUser?.userType == .female)
        }

        @Test("Repository should preserve other properties when updating")
        func testUpdatePreservesProperties() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let profile = UserProfile(name: "Test", userType: .male)
            try await repository.save(profile)
            let originalCreatedAt = profile.createdAt

            // Act
            profile.name = "Modified"
            try await repository.update(profile)

            // Assert
            let fetchedUser = try await repository.getCurrentUser()
            #expect(fetchedUser?.createdAt == originalCreatedAt)
        }
    }

    @Suite("Delete Tests")
    struct DeleteTests {
        @Test("Repository should delete user profile")
        func testDeleteUser() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let profile = UserProfile(name: "To Delete", userType: .male)
            try await repository.save(profile)

            // Act
            try await repository.delete(profile)

            // Assert
            let fetchedUser = try await repository.getCurrentUser()
            #expect(fetchedUser == nil)
        }

        @Test("Repository should handle deleting when empty")
        func testDeleteWhenEmpty() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let profile = UserProfile(name: "Test", userType: .male)

            // Act & Assert - should not throw
            try await repository.delete(profile)
        }

        @Test("Repository should delete all users")
        func testDeleteAll() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let user1 = UserProfile(name: "User 1", userType: .male)
            let user2 = UserProfile(name: "User 2", userType: .female)
            try await repository.save(user1)
            try await repository.save(user2)

            // Act
            try await repository.deleteAll()

            // Assert
            let allUsers = try await repository.getAllUsers()
            #expect(allUsers.isEmpty)
        }
    }

    @Suite("Error Handling Tests")
    struct ErrorHandlingTests {
        @Test("Repository should handle save errors gracefully")
        func testSaveErrorHandling() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let profile = UserProfile(name: "Test", userType: .male)

            // Act & Assert - should not throw for valid profile
            try await repository.save(profile)
        }
    }

    @Suite("Integration Tests")
    struct IntegrationTests {
        @Test("Repository should work with complete CRUD cycle")
        func testCompleteCRUDCycle() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            // Create
            let profile = UserProfile(name: "CRUD Test", userType: .male)
            try await repository.save(profile)

            // Read
            var fetchedUser = try await repository.getCurrentUser()
            #expect(fetchedUser?.name == "CRUD Test")

            // Update
            profile.name = "CRUD Updated"
            try await repository.update(profile)
            fetchedUser = try await repository.getCurrentUser()
            #expect(fetchedUser?.name == "CRUD Updated")

            // Delete
            try await repository.delete(profile)
            fetchedUser = try await repository.getCurrentUser()
            #expect(fetchedUser == nil)
        }
    }

    @Suite("Sprint 6 Extension Tests")
    struct Sprint6ExtensionTests {
        @Test("Repository should update special needs")
        func testUpdateSpecialNeeds() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let profile = UserProfile(name: "Test User", userType: .female)
            try await repository.save(profile)

            // Act
            try await repository.updateSpecialNeeds(.pregnant)

            // Assert
            let fetchedUser = try await repository.getCurrentUser()
            #expect(fetchedUser?.specialNeeds == .pregnant)
        }

        @Test("Repository should handle updating special needs when no user exists")
        func testUpdateSpecialNeedsNoUser() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            // Act & Assert - should not throw even when no user exists
            try await repository.updateSpecialNeeds(.pregnant)
        }

        @Test("Repository should update to different special needs")
        func testUpdateSpecialNeedsMultipleTimes() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let profile = UserProfile(name: "Test User", userType: .female)
            profile.specialNeeds = .pregnant
            try await repository.save(profile)

            // Act
            try await repository.updateSpecialNeeds(.breastfeeding)

            // Assert
            let fetchedUser = try await repository.getCurrentUser()
            #expect(fetchedUser?.specialNeeds == .breastfeeding)
        }

        @Test("Repository should mark onboarding as complete")
        func testMarkOnboardingComplete() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let profile = UserProfile(name: "Test User", userType: .male)
            #expect(profile.hasCompletedOnboarding == false)
            try await repository.save(profile)

            // Act
            try await repository.markOnboardingComplete()

            // Assert
            let fetchedUser = try await repository.getCurrentUser()
            #expect(fetchedUser?.hasCompletedOnboarding == true)
        }

        @Test("Repository should handle marking onboarding complete when no user exists")
        func testMarkOnboardingCompleteNoUser() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            // Act & Assert - should not throw even when no user exists
            try await repository.markOnboardingComplete()
        }

        @Test("Repository should check if onboarding has been completed")
        func testHasCompletedOnboarding() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let profile = UserProfile(name: "Test User", userType: .male)
            profile.hasCompletedOnboarding = true
            try await repository.save(profile)

            // Act
            let hasCompleted = try await repository.hasCompletedOnboarding()

            // Assert
            #expect(hasCompleted == true)
        }

        @Test("Repository should return false when onboarding not completed")
        func testHasCompletedOnboardingFalse() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let profile = UserProfile(name: "Test User", userType: .male)
            #expect(profile.hasCompletedOnboarding == false)
            try await repository.save(profile)

            // Act
            let hasCompleted = try await repository.hasCompletedOnboarding()

            // Assert
            #expect(hasCompleted == false)
        }

        @Test("Repository should return false when no user exists")
        func testHasCompletedOnboardingNoUser() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            // Act
            let hasCompleted = try await repository.hasCompletedOnboarding()

            // Assert
            #expect(hasCompleted == false)
        }

        @Test("Repository should persist onboarding status across fetches")
        func testOnboardingStatusPersistence() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)
            let repository = UserRepository(modelContext: context)

            let profile = UserProfile(name: "Test User", userType: .male)
            try await repository.save(profile)

            // Act
            try await repository.markOnboardingComplete()

            // Assert - Check multiple times
            let hasCompleted1 = try await repository.hasCompletedOnboarding()
            let hasCompleted2 = try await repository.hasCompletedOnboarding()
            #expect(hasCompleted1 == true)
            #expect(hasCompleted2 == true)
        }
    }
}
