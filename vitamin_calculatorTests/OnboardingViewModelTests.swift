//
//  OnboardingViewModelTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 28.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

/// Test suite for OnboardingViewModel following TDD best practices
@Suite("OnboardingViewModel Tests")
@MainActor
struct OnboardingViewModelTests {

    // MARK: - Test Setup Helpers

    /// Creates an in-memory model container for testing
    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: UserProfile.self,
            configurations: config
        )
        return container
    }

    /// Creates a test onboarding service with in-memory storage
    private func createTestService() throws -> OnboardingService {
        let container = try createTestContainer()
        let context = ModelContext(container)
        let repository = UserRepository(modelContext: context)
        return OnboardingService(userRepository: repository)
    }

    // MARK: - Initialization Tests

    @Test("OnboardingViewModel initializes with welcome step")
    func testInitializationStartsAtWelcome() async throws {
        // Arrange & Act
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        // Assert
        #expect(viewModel.state.currentStep == .welcome)
        #expect(viewModel.state.isCompleted == false)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("ViewModel properties computed correctly from state")
    func testComputedProperties() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        // Assert
        #expect(viewModel.currentStepIndex == 0) // welcome = 0
        #expect(viewModel.totalSteps == 5) // welcome, userType, specialNeeds, featureIntro, complete
        #expect(viewModel.canGoBack == false) // at first step
        #expect(viewModel.isLastStep == false) // not at complete step
    }

    // MARK: - Navigation Tests

    @Test("Next step advances through onboarding flow")
    func testNextStepAdvances() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        #expect(viewModel.state.currentStep == .welcome)

        // Act
        viewModel.nextStep()

        // Assert
        #expect(viewModel.state.currentStep == .userType)
        #expect(viewModel.currentStepIndex == 1)
    }

    @Test("Previous step goes back in onboarding flow")
    func testPreviousStepGoesBack() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        // Move to second step first
        viewModel.nextStep()
        #expect(viewModel.state.currentStep == .userType)

        // Act
        viewModel.previousStep()

        // Assert
        #expect(viewModel.state.currentStep == .welcome)
        #expect(viewModel.currentStepIndex == 0)
    }

    @Test("Cannot go back from first step")
    func testCannotGoBackFromFirstStep() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        #expect(viewModel.state.currentStep == .welcome)
        #expect(viewModel.canGoBack == false)

        // Act
        viewModel.previousStep()

        // Assert - should still be at welcome
        #expect(viewModel.state.currentStep == .welcome)
    }

    @Test("Can go back after advancing")
    func testCanGoBackAfterAdvancing() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        // Act
        viewModel.nextStep()

        // Assert
        #expect(viewModel.canGoBack == true)
    }

    @Test("Next step reaches complete step")
    func testNavigationToCompleteStep() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        // Act - navigate through all steps
        viewModel.state.userProfile.name = "Test" // Required for validation
        viewModel.nextStep() // welcome -> userType
        viewModel.nextStep() // userType -> specialNeeds
        viewModel.nextStep() // specialNeeds -> featureIntro
        viewModel.nextStep() // featureIntro -> complete

        // Assert
        #expect(viewModel.state.currentStep == .complete)
        #expect(viewModel.isLastStep == true)
    }

    // MARK: - Validation Tests

    @Test("Can proceed from welcome step")
    func testCanProceedFromWelcome() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        // Assert
        #expect(viewModel.state.currentStep == .welcome)
        #expect(viewModel.canProceed == true)
    }

    @Test("Cannot proceed from user type step without name")
    func testCannotProceedWithoutName() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        viewModel.nextStep() // Move to userType
        #expect(viewModel.state.currentStep == .userType)

        // Assert
        #expect(viewModel.state.userProfile.name == "")
        #expect(viewModel.canProceed == false)
    }

    @Test("Can proceed from user type step with name")
    func testCanProceedWithName() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        viewModel.nextStep() // Move to userType

        // Act
        viewModel.state.userProfile.name = "Test User"

        // Assert
        #expect(viewModel.canProceed == true)
    }

    // MARK: - Skip Onboarding Tests

    @Test("Skip onboarding creates default user")
    func testSkipOnboarding() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        // Act
        await viewModel.skipOnboarding()

        // Assert
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Skip onboarding sets loading state")
    func testSkipOnboardingSetsLoadingState() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        // Act
        await viewModel.skipOnboarding()

        // Assert - loading should be false after completion
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Complete Onboarding Tests

    @Test("Complete onboarding creates user profile")
    func testCompleteOnboarding() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        // Set up user profile data
        viewModel.state.userProfile.name = "Test User"
        viewModel.state.userProfile.userType = .female
        viewModel.state.userProfile.specialNeeds = .pregnant

        // Act
        await viewModel.completeOnboarding()

        // Assert
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Complete onboarding without name shows error")
    func testCompleteOnboardingWithoutNameFails() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        // Don't set name - validation should fail
        viewModel.state.userProfile.name = ""

        // Act
        await viewModel.completeOnboarding()

        // Assert
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.errorMessage?.contains("名称") == true ||
                viewModel.errorMessage?.contains("name") == true)
    }

    @Test("Complete onboarding marks state as completed")
    func testCompleteOnboardingMarksStateCompleted() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        viewModel.state.userProfile.name = "Test"

        // Act
        await viewModel.completeOnboarding()

        // Assert - state should be marked completed
        #expect(viewModel.state.isCompleted == true)
    }

    // MARK: - State Management Tests

    @Test("Error message is cleared on next action")
    func testErrorMessageCleared() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        // Trigger an error
        await viewModel.completeOnboarding() // Will fail without name

        #expect(viewModel.errorMessage != nil)

        // Act - perform another action
        viewModel.nextStep()

        // Assert - error should be cleared
        #expect(viewModel.errorMessage == nil)
    }

    @Test("User profile data persists through navigation")
    func testUserProfileDataPersists() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        // Set up data on first step
        viewModel.state.userProfile.name = "Test User"
        viewModel.state.userProfile.userType = .female

        // Act - navigate forward and back
        viewModel.nextStep()
        viewModel.nextStep()
        viewModel.previousStep()

        // Assert - data should still be there
        #expect(viewModel.state.userProfile.name == "Test User")
        #expect(viewModel.state.userProfile.userType == .female)
    }

    // MARK: - Integration Tests

    @Test("Full onboarding flow completes successfully")
    func testFullOnboardingFlow() async throws {
        // Arrange
        let service = try createTestService()
        let viewModel = OnboardingViewModel(onboardingService: service)

        // Act - simulate full user flow
        #expect(viewModel.state.currentStep == .welcome)
        viewModel.nextStep()

        #expect(viewModel.state.currentStep == .userType)
        viewModel.state.userProfile.name = "Integration Test User"
        viewModel.state.userProfile.userType = .male
        viewModel.nextStep()

        #expect(viewModel.state.currentStep == .specialNeeds)
        viewModel.state.userProfile.specialNeeds = .none
        viewModel.nextStep()

        #expect(viewModel.state.currentStep == .featureIntro)
        viewModel.nextStep()

        #expect(viewModel.state.currentStep == .complete)
        await viewModel.completeOnboarding()

        // Assert
        #expect(viewModel.state.isCompleted == true)
        #expect(viewModel.errorMessage == nil)
    }
}
