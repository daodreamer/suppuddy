//
//  Sprint6IntegrationTests.swift
//  vitamin_calculatorTests
//
//  Created for Sprint 6 - Phase 7.1
//  End-to-end integration tests
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("Sprint 6 Integration Tests - Phase 7")
struct Sprint6IntegrationTests {

    // MARK: - Onboarding Flow Integration Tests

    @Suite("Complete Onboarding Flow")
    struct OnboardingFlowTests {

        @Test("Complete onboarding flow creates user profile with correct settings")
        @MainActor
        func testCompleteOnboardingFlow() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let repository = UserRepository(modelContext: context)
            let onboardingService = OnboardingService(userRepository: repository)

            // Verify no user exists initially
            let shouldShow = try await onboardingService.shouldShowOnboarding()
            #expect(shouldShow == true, "Should show onboarding for new user")

            // Act - Complete onboarding with user data
            let draft = UserProfileDraft(
                name: "Test User",
                userType: .female,
                birthDate: nil,
                specialNeeds: .pregnant
            )

            let profile = try await onboardingService.completeOnboarding(draft: draft)

            // Assert - Profile is created correctly
            #expect(profile.name == "Test User")
            #expect(profile.userType == .female)
            #expect(profile.specialNeeds == .pregnant)
            #expect(profile.hasCompletedOnboarding == true)

            // Verify onboarding should not show again
            let shouldShowAgain = try await onboardingService.shouldShowOnboarding()
            #expect(shouldShowAgain == false, "Should not show onboarding after completion")
        }

        @Test("Onboarding flow with special needs affects recommendations")
        @MainActor
        func testOnboardingFlowWithSpecialNeedsRecommendations() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let repository = UserRepository(modelContext: context)
            let onboardingService = OnboardingService(userRepository: repository)
            let recommendationService = RecommendationService()

            // Act - Complete onboarding with pregnant user
            let draft = UserProfileDraft(
                name: "Pregnant User",
                userType: .female,
                birthDate: nil,
                specialNeeds: .pregnant
            )

            let profile = try await onboardingService.completeOnboarding(draft: draft)

            // Assert - Recommendations reflect special needs
            let folateRec = recommendationService.getRecommendation(for: .folate, user: profile)
            #expect(folateRec?.recommendedAmount == 550.0,
                   "Pregnant user should get higher folate recommendation")

            let ironRec = recommendationService.getRecommendation(for: .iron, user: profile)
            #expect(ironRec?.recommendedAmount == 30.0,
                   "Pregnant user should get higher iron recommendation")
        }
    }

    // MARK: - User Profile Editing Flow Tests

    @Suite("User Profile Editing Flow")
    struct UserProfileEditingFlowTests {

        @Test("User can update profile and recommendations change accordingly")
        func testUserProfileUpdateAffectsRecommendations() throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let recommendationService = RecommendationService()

            // Create initial user profile
            let profile = UserProfile(name: "Test User", userType: .female)
            context.insert(profile)
            try context.save()

            // Get initial recommendations
            let initialFolate = recommendationService.getRecommendation(for: .folate, user: profile)
            #expect(initialFolate?.recommendedAmount == 300.0, "Normal female folate")

            // Act - Update user to pregnant
            profile.specialNeeds = .pregnant
            try context.save()

            // Assert - Recommendations update
            let updatedFolate = recommendationService.getRecommendation(for: .folate, user: profile)
            #expect(updatedFolate?.recommendedAmount == 550.0,
                   "Folate recommendation should increase for pregnancy")

            // Act - Update to breastfeeding
            profile.specialNeeds = .breastfeeding
            try context.save()

            // Assert - Recommendations update again
            let breastfeedingFolate = recommendationService.getRecommendation(for: .folate, user: profile)
            #expect(breastfeedingFolate?.recommendedAmount == 450.0,
                   "Folate recommendation should change for breastfeeding")
        }

        @Test("Switching from pregnant to none removes special recommendations")
        func testRemovingSpecialNeeds() throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let recommendationService = RecommendationService()

            let profile = UserProfile(name: "Test User", userType: .female)
            profile.specialNeeds = .pregnant
            context.insert(profile)
            try context.save()

            // Verify pregnant recommendations
            let pregnantIodine = recommendationService.getRecommendation(for: .iodine, user: profile)
            #expect(pregnantIodine?.recommendedAmount == 220.0, "Pregnant iodine should be 220 (DGE 2025/2026)")

            // Act - Remove special needs
            profile.specialNeeds = SpecialNeeds.none
            try context.save()

            // Assert - Back to normal recommendations
            let normalIodine = recommendationService.getRecommendation(for: .iodine, user: profile)
            #expect(normalIodine?.recommendedAmount == 200.0, "Normal female iodine should be 200")
        }
    }

    // MARK: - Data Export/Import Flow Tests

    @Suite("Data Export and Import Flow")
    struct DataExportImportFlowTests {

        @Test("Complete data export and import cycle preserves user data")
        @MainActor
        func testDataExportImportCycle() async throws {
            // Arrange - Create test data
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let userRepo = UserRepository(modelContext: context)
            let supplementRepo = SupplementRepository(modelContext: context)
            let intakeRepo = IntakeRecordRepository(modelContext: context)

            let exportService = DataExportService(
                userRepository: userRepo,
                supplementRepository: supplementRepo,
                intakeRepository: intakeRepo
            )
            let importService = DataImportService(
                userRepository: userRepo,
                supplementRepository: supplementRepo,
                intakeRepository: intakeRepo
            )

            // Create user profile
            let originalProfile = UserProfile(name: "Export Test User", userType: .female)
            originalProfile.specialNeeds = .breastfeeding
            context.insert(originalProfile)
            try context.save()

            // Act - Export data
            let exportData = try await exportService.collectExportData()

            // Assert - Export contains user data
            #expect(exportData.userProfile != nil, "Export should contain user profile")
            #expect(exportData.userProfile?.name == "Export Test User")
            #expect(exportData.userProfile?.specialNeeds == "breastfeeding")

            // Verify export can be serialized to JSON
            let jsonData = try exportData.toJSON()
            #expect(jsonData.count > 0, "Export should produce valid JSON")

            // Act - Import the data back (in replace mode)
            let importResult = try await importService.performImport(exportData, mode: .replace)

            // Assert - Import successful
            #expect(importResult.errors.count == 0, "Import should have no errors")
        }

        @Test("Import detects conflicts correctly")
        @MainActor
        func testImportConflictDetection() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let userRepo = UserRepository(modelContext: context)
            let supplementRepo = SupplementRepository(modelContext: context)
            let intakeRepo = IntakeRecordRepository(modelContext: context)

            let importService = DataImportService(
                userRepository: userRepo,
                supplementRepository: supplementRepo,
                intakeRepository: intakeRepo
            )

            // Create export data
            let exportData = ExportData(
                exportDate: Date(),
                appVersion: "1.0.0",
                userProfile: ExportedUserProfile(
                    name: "Conflict User",
                    userType: "female",
                    specialNeeds: "pregnant"
                ),
                supplements: [],
                intakeRecords: [],
                reminders: []
            )

            // Act - Validate
            let errors = importService.validateImportData(exportData)

            // Assert - No validation errors for valid data
            #expect(errors.count == 0, "Valid data should pass validation")
        }
    }

    // MARK: - Recommendation Integration Tests

    @Suite("Recommendation Value Integration")
    struct RecommendationIntegrationTests {

        @Test("All pregnancy nutrients have valid recommendations")
        func testPregnancyNutrientsCompleteness() {
            // Arrange
            let recommendationService = RecommendationService()
            let pregnantUser = UserProfile(name: "Pregnant", userType: .female)
            pregnantUser.specialNeeds = .pregnant

            // Act
            let allRecommendations = recommendationService.getAllRecommendations(for: pregnantUser)

            // Assert - All nutrients have recommendations
            #expect(allRecommendations.count == 23, "Should have all 23 nutrients")

            // Verify key pregnancy nutrients have special values
            let folate = allRecommendations.first { $0.nutrientType == .folate }
            #expect(folate?.recommendedAmount == 550.0)

            let iron = allRecommendations.first { $0.nutrientType == .iron }
            #expect(iron?.recommendedAmount == 30.0)

            let iodine = allRecommendations.first { $0.nutrientType == .iodine }
            #expect(iodine?.recommendedAmount == 220.0, "Should use DGE 2025/2026 value")

            let vitaminE = allRecommendations.first { $0.nutrientType == .vitaminE }
            #expect(vitaminE?.recommendedAmount == 8.0, "Should use DGE 2025/2026 value")

            let vitaminB6 = allRecommendations.first { $0.nutrientType == .vitaminB6 }
            #expect(vitaminB6?.recommendedAmount == 1.9)

            let vitaminB12 = allRecommendations.first { $0.nutrientType == .vitaminB12 }
            #expect(vitaminB12?.recommendedAmount == 4.5)

            let magnesium = allRecommendations.first { $0.nutrientType == .magnesium }
            #expect(magnesium?.recommendedAmount == 310.0)

            let zinc = allRecommendations.first { $0.nutrientType == .zinc }
            #expect(zinc?.recommendedAmount == 11.0)
        }

        @Test("All breastfeeding nutrients have valid recommendations")
        func testBreastfeedingNutrientsCompleteness() {
            // Arrange
            let recommendationService = RecommendationService()
            let breastfeedingUser = UserProfile(name: "Breastfeeding", userType: .female)
            breastfeedingUser.specialNeeds = .breastfeeding

            // Act
            let allRecommendations = recommendationService.getAllRecommendations(for: breastfeedingUser)

            // Assert - All nutrients have recommendations
            #expect(allRecommendations.count == 23, "Should have all 23 nutrients")

            // Verify key breastfeeding nutrients have special values
            let folate = allRecommendations.first { $0.nutrientType == .folate }
            #expect(folate?.recommendedAmount == 450.0)

            let iron = allRecommendations.first { $0.nutrientType == .iron }
            #expect(iron?.recommendedAmount == 20.0)

            let iodine = allRecommendations.first { $0.nutrientType == .iodine }
            #expect(iodine?.recommendedAmount == 230.0, "Should use DGE 2025/2026 value")

            let vitaminE = allRecommendations.first { $0.nutrientType == .vitaminE }
            #expect(vitaminE?.recommendedAmount == 13.0, "Should use DGE 2025/2026 value")

            let vitaminB6 = allRecommendations.first { $0.nutrientType == .vitaminB6 }
            #expect(vitaminB6?.recommendedAmount == 1.6)

            let vitaminB12 = allRecommendations.first { $0.nutrientType == .vitaminB12 }
            #expect(vitaminB12?.recommendedAmount == 5.5)

            let magnesium = allRecommendations.first { $0.nutrientType == .magnesium }
            #expect(magnesium?.recommendedAmount == 390.0)

            let zinc = allRecommendations.first { $0.nutrientType == .zinc }
            #expect(zinc?.recommendedAmount == 13.0)
        }

        @Test("Child age groups have appropriate recommendations")
        func testChildAgeGroupRecommendations() {
            // Arrange
            let recommendationService = RecommendationService()
            let ageGroups = [4, 7, 10, 13, 16]

            // Act & Assert - Each age group has recommendations
            for age in ageGroups {
                let child = UserProfile(name: "Child \(age)", userType: .child(age: age))
                let recommendations = recommendationService.getAllRecommendations(for: child)

                #expect(recommendations.count == 23,
                       "Child age \(age) should have all 23 nutrients")

                // Verify recommendations increase with age for key nutrients
                let calcium = recommendations.first { $0.nutrientType == .calcium }
                #expect(calcium != nil && calcium!.recommendedAmount > 0,
                       "Child age \(age) should have calcium recommendation")
            }
        }
    }
}
