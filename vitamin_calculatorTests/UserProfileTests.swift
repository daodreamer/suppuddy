//
//  UserProfileTests.swift
//  vitamin_calculatorTests
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Foundation
import SwiftData
import Testing
@testable import vitamin_calculator

@Suite("UserProfile Model Tests")
struct UserProfileTests {

    @Suite("Initialization Tests")
    struct InitializationTests {
        @Test("UserProfile should initialize with name and user type")
        func testBasicInitialization() {
            // Arrange & Act
            let profile = UserProfile(name: "Test User", userType: .male)

            // Assert
            #expect(profile.name == "Test User")
            #expect(profile.userType == .male)
        }

        @Test("UserProfile should initialize with female user type")
        func testFemaleInitialization() {
            // Arrange & Act
            let profile = UserProfile(name: "Jane", userType: .female)

            // Assert
            #expect(profile.name == "Jane")
            #expect(profile.userType == .female)
        }

        @Test("UserProfile should initialize with child user type")
        func testChildInitialization() {
            // Arrange & Act
            let profile = UserProfile(name: "Child", userType: .child(age: 10))

            // Assert
            #expect(profile.name == "Child")
            if case .child(let age) = profile.userType {
                #expect(age == 10)
            } else {
                Issue.record("UserType should be child")
            }
        }
    }

    @Suite("SwiftData Persistence Tests")
    struct PersistenceTests {
        @Test("UserProfile should persist with SwiftData")
        func testUserProfilePersistence() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let profile = UserProfile(
                name: "Test User",
                userType: .male
            )

            // Act
            context.insert(profile)
            try context.save()

            // Assert
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try context.fetch(descriptor)

            #expect(profiles.count == 1)
            #expect(profiles.first?.name == "Test User")
            #expect(profiles.first?.userType == .male)
        }

        @Test("UserProfile should update properties")
        func testUserProfileUpdate() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let profile = UserProfile(name: "User", userType: .male)
            context.insert(profile)
            try context.save()

            // Act
            profile.name = "Updated Name"
            profile.userType = .female
            try context.save()

            // Assert
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try context.fetch(descriptor)

            #expect(profiles.count == 1)
            #expect(profiles.first?.name == "Updated Name")
            #expect(profiles.first?.userType == .female)
        }

        @Test("UserProfile should delete from database")
        func testUserProfileDeletion() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let profile = UserProfile(name: "To Delete", userType: .male)
            context.insert(profile)
            try context.save()

            // Act
            context.delete(profile)
            try context.save()

            // Assert
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try context.fetch(descriptor)

            #expect(profiles.isEmpty)
        }

        @Test("Multiple UserProfiles should persist")
        func testMultipleProfiles() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let profile1 = UserProfile(name: "User 1", userType: .male)
            let profile2 = UserProfile(name: "User 2", userType: .female)
            let profile3 = UserProfile(name: "User 3", userType: .child(age: 12))

            // Act
            context.insert(profile1)
            context.insert(profile2)
            context.insert(profile3)
            try context.save()

            // Assert
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try context.fetch(descriptor)

            #expect(profiles.count == 3)
        }
    }

    @Suite("Property Tests")
    struct PropertyTests {
        @Test("UserProfile name should be mutable")
        func testNameMutability() {
            // Arrange
            let profile = UserProfile(name: "Original", userType: .male)

            // Act
            profile.name = "Modified"

            // Assert
            #expect(profile.name == "Modified")
        }

        @Test("UserProfile userType should be mutable")
        func testUserTypeMutability() {
            // Arrange
            let profile = UserProfile(name: "Test", userType: .male)

            // Act
            profile.userType = .female

            // Assert
            #expect(profile.userType == .female)
        }

        @Test("UserProfile should handle empty name")
        func testEmptyName() {
            // Arrange & Act
            let profile = UserProfile(name: "", userType: .male)

            // Assert
            #expect(profile.name == "")
        }

        @Test("UserProfile should handle long names")
        func testLongName() {
            // Arrange
            let longName = String(repeating: "A", count: 100)

            // Act
            let profile = UserProfile(name: longName, userType: .male)

            // Assert
            #expect(profile.name == longName)
        }
    }

    @Suite("Query Tests")
    struct QueryTests {
        @Test("Should query profiles by name")
        func testQueryByName() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let profile1 = UserProfile(name: "Alice", userType: .female)
            let profile2 = UserProfile(name: "Bob", userType: .male)

            context.insert(profile1)
            context.insert(profile2)
            try context.save()

            // Act
            let predicate = #Predicate<UserProfile> { profile in
                profile.name == "Alice"
            }
            let descriptor = FetchDescriptor<UserProfile>(predicate: predicate)
            let results = try context.fetch(descriptor)

            // Assert
            #expect(results.count == 1)
            #expect(results.first?.name == "Alice")
        }

        @Test("Should fetch all profiles")
        func testFetchAllProfiles() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let profile1 = UserProfile(name: "Male User", userType: .male)
            let profile2 = UserProfile(name: "Female User", userType: .female)
            let profile3 = UserProfile(name: "Another Male", userType: .male)

            context.insert(profile1)
            context.insert(profile2)
            context.insert(profile3)
            try context.save()

            // Act
            let descriptor = FetchDescriptor<UserProfile>()
            let results = try context.fetch(descriptor)

            // Assert
            #expect(results.count == 3)
        }
    }

    @Suite("Sprint 6 Extension Tests")
    struct ExtensionTests {
        @Test("UserProfile should initialize with default values for new fields")
        func testDefaultValuesForNewFields() {
            // Arrange & Act
            let profile = UserProfile(name: "Test", userType: .male)

            // Assert
            #expect(profile.birthDate == nil)
            #expect(profile.specialNeeds == nil)
            #expect(profile.hasCompletedOnboarding == false)
        }

        @Test("UserProfile should store and retrieve special needs")
        func testSpecialNeeds() {
            // Arrange
            let profile = UserProfile(name: "Test", userType: .female)

            // Act
            profile.specialNeeds = .pregnant

            // Assert
            #expect(profile.specialNeeds == .pregnant)
        }

        @Test("UserProfile should persist special needs")
        func testSpecialNeedsPersistence() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let profile = UserProfile(name: "Test", userType: .female)
            profile.specialNeeds = .breastfeeding

            // Act
            context.insert(profile)
            try context.save()

            // Assert
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try context.fetch(descriptor)
            #expect(profiles.count == 1)
            #expect(profiles.first?.specialNeeds == .breastfeeding)
        }

        @Test("UserProfile should calculate age from birthDate")
        func testAgeCalculation() {
            // Arrange
            let profile = UserProfile(name: "Test", userType: .male)
            let calendar = Calendar.current
            let birthDate = calendar.date(byAdding: .year, value: -30, to: Date())!

            // Act
            profile.birthDate = birthDate

            // Assert
            #expect(profile.age == 30)
        }

        @Test("UserProfile should return nil age when birthDate is nil")
        func testAgeWithoutBirthDate() {
            // Arrange
            let profile = UserProfile(name: "Test", userType: .male)

            // Act & Assert
            #expect(profile.age == nil)
        }

        @Test("UserProfile should determine child age group from birthDate")
        func testChildAgeGroupFromBirthDate() {
            // Arrange
            let profile = UserProfile(name: "Child", userType: .child(age: 5))
            let calendar = Calendar.current
            let birthDate = calendar.date(byAdding: .year, value: -5, to: Date())!

            // Act
            profile.birthDate = birthDate

            // Assert
            #expect(profile.childAgeGroup == .age4to6)
        }

        @Test("UserProfile should determine child age group from UserType")
        func testChildAgeGroupFromUserType() {
            // Arrange & Act
            let profile = UserProfile(name: "Child", userType: .child(age: 8))

            // Assert
            #expect(profile.childAgeGroup == .age7to9)
        }

        @Test("UserProfile should return nil child age group for adults")
        func testChildAgeGroupForAdults() {
            // Arrange & Act
            let profile = UserProfile(name: "Adult", userType: .male)

            // Assert
            #expect(profile.childAgeGroup == nil)
        }

        @Test("UserProfile should track onboarding completion")
        func testOnboardingCompletion() {
            // Arrange
            let profile = UserProfile(name: "Test", userType: .male)

            // Act
            profile.hasCompletedOnboarding = true

            // Assert
            #expect(profile.hasCompletedOnboarding == true)
        }

        @Test("UserProfile should persist onboarding status")
        func testOnboardingPersistence() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let profile = UserProfile(name: "Test", userType: .male)
            profile.hasCompletedOnboarding = true

            // Act
            context.insert(profile)
            try context.save()

            // Assert
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try context.fetch(descriptor)
            #expect(profiles.count == 1)
            #expect(profiles.first?.hasCompletedOnboarding == true)
        }

        @Test("UserProfile should persist birthDate")
        func testBirthDatePersistence() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let profile = UserProfile(name: "Test", userType: .male)
            let testDate = Date(timeIntervalSince1970: 631152000) // 1990-01-01
            profile.birthDate = testDate

            // Act
            context.insert(profile)
            try context.save()

            // Assert
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try context.fetch(descriptor)
            #expect(profiles.count == 1)
            #expect(profiles.first?.birthDate == testDate)
        }
    }

    @Suite("Edge Case Tests")
    struct EdgeCaseTests {
        @Test("UserProfile should persist child with different ages")
        func testChildrenWithDifferentAges() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let ages = [0, 5, 10, 15, 17]

            // Act
            for age in ages {
                let profile = UserProfile(
                    name: "Child \(age)",
                    userType: .child(age: age)
                )
                context.insert(profile)
            }
            try context.save()

            // Assert
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try context.fetch(descriptor)

            #expect(profiles.count == ages.count)
        }

        @Test("UserProfile should handle special characters in name")
        func testSpecialCharactersInName() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self,
                configurations: config
            )
            let context = ModelContext(container)

            let specialNames = [
                "João",
                "François",
                "北京",
                "Москва",
                "😊 User"
            ]

            // Act
            for name in specialNames {
                let profile = UserProfile(name: name, userType: .male)
                context.insert(profile)
            }
            try context.save()

            // Assert
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = try context.fetch(descriptor)

            #expect(profiles.count == specialNames.count)
        }
    }
}
