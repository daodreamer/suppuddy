//
//  OnboardingStateTests.swift
//  vitamin_calculatorTests
//
//  Created for Sprint 6 - Task 1.3
//  TDD: Red phase - writing tests first
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("OnboardingState Model Tests")
struct OnboardingStateTests {

    @Suite("OnboardingStep Enum Tests")
    struct OnboardingStepTests {
        @Test("OnboardingStep should have correct raw values")
        func testRawValues() {
            // Assert
            #expect(OnboardingStep.welcome.rawValue == 0)
            #expect(OnboardingStep.userType.rawValue == 1)
            #expect(OnboardingStep.specialNeeds.rawValue == 2)
            #expect(OnboardingStep.featureIntro.rawValue == 3)
            #expect(OnboardingStep.complete.rawValue == 4)
        }

        @Test("OnboardingStep should have all 5 cases")
        func testAllCases() {
            // Act
            let allCases = OnboardingStep.allCases

            // Assert
            #expect(allCases.count == 5)
            #expect(allCases.contains(.welcome))
            #expect(allCases.contains(.userType))
            #expect(allCases.contains(.specialNeeds))
            #expect(allCases.contains(.featureIntro))
            #expect(allCases.contains(.complete))
        }

        @Test("OnboardingStep welcome should have title")
        func testWelcomeTitle() {
            // Arrange
            let step = OnboardingStep.welcome

            // Act & Assert
            #expect(!step.title.isEmpty)
        }

        @Test("OnboardingStep should have non-empty titles")
        func testAllStepTitles() {
            // Arrange
            let steps = OnboardingStep.allCases

            // Act & Assert
            for step in steps {
                #expect(!step.title.isEmpty)
            }
        }

        @Test("OnboardingStep should have non-empty descriptions")
        func testAllStepDescriptions() {
            // Arrange
            let steps = OnboardingStep.allCases

            // Act & Assert
            for step in steps {
                #expect(!step.description.isEmpty)
            }
        }
    }

    @Suite("UserProfileDraft Tests")
    struct UserProfileDraftTests {
        @Test("UserProfileDraft should initialize with default values")
        func testDefaultInitialization() {
            // Arrange & Act
            let draft = UserProfileDraft()

            // Assert
            #expect(draft.name == "")
            #expect(draft.userType == .male)
            #expect(draft.birthDate == nil)
            #expect(draft.specialNeeds == .none)
        }

        @Test("UserProfileDraft should allow setting name")
        func testSetName() {
            // Arrange
            var draft = UserProfileDraft()

            // Act
            draft.name = "Test User"

            // Assert
            #expect(draft.name == "Test User")
        }

        @Test("UserProfileDraft should allow setting userType")
        func testSetUserType() {
            // Arrange
            var draft = UserProfileDraft()

            // Act
            draft.userType = .female

            // Assert
            #expect(draft.userType == .female)
        }

        @Test("UserProfileDraft should allow setting birthDate")
        func testSetBirthDate() {
            // Arrange
            var draft = UserProfileDraft()
            let date = Date()

            // Act
            draft.birthDate = date

            // Assert
            #expect(draft.birthDate == date)
        }

        @Test("UserProfileDraft should allow setting specialNeeds")
        func testSetSpecialNeeds() {
            // Arrange
            var draft = UserProfileDraft()

            // Act
            draft.specialNeeds = .pregnant

            // Assert
            #expect(draft.specialNeeds == .pregnant)
        }
    }

    @Suite("OnboardingState Tests")
    struct OnboardingStateMainTests {
        @Test("OnboardingState should initialize with welcome step")
        func testDefaultInitialization() {
            // Arrange & Act
            let state = OnboardingState()

            // Assert
            #expect(state.currentStep == .welcome)
            #expect(state.isCompleted == false)
        }

        @Test("OnboardingState should initialize with custom draft")
        func testInitializationWithDraft() {
            // Arrange
            var draft = UserProfileDraft()
            draft.name = "Test"
            draft.userType = .female

            // Act
            let state = OnboardingState(userProfile: draft)

            // Assert
            #expect(state.userProfile.name == "Test")
            #expect(state.userProfile.userType == .female)
        }

        @Test("nextStep should advance to userType step")
        func testNextStepFromWelcome() {
            // Arrange
            var state = OnboardingState()

            // Act
            state.nextStep()

            // Assert
            #expect(state.currentStep == .userType)
        }

        @Test("nextStep should advance through all steps")
        func testNextStepProgression() {
            // Arrange
            var state = OnboardingState()

            // Act & Assert
            #expect(state.currentStep == .welcome)

            state.nextStep()
            #expect(state.currentStep == .userType)

            state.nextStep()
            #expect(state.currentStep == .specialNeeds)

            state.nextStep()
            #expect(state.currentStep == .featureIntro)

            state.nextStep()
            #expect(state.currentStep == .complete)
        }

        @Test("nextStep should not advance beyond complete step")
        func testNextStepAtEnd() {
            // Arrange
            var state = OnboardingState()
            state.currentStep = .complete

            // Act
            state.nextStep()

            // Assert
            #expect(state.currentStep == .complete)
        }

        @Test("previousStep should go back to previous step")
        func testPreviousStep() {
            // Arrange
            var state = OnboardingState()
            state.currentStep = .userType

            // Act
            state.previousStep()

            // Assert
            #expect(state.currentStep == .welcome)
        }

        @Test("previousStep should not go before welcome")
        func testPreviousStepAtStart() {
            // Arrange
            var state = OnboardingState()
            #expect(state.currentStep == .welcome)

            // Act
            state.previousStep()

            // Assert
            #expect(state.currentStep == .welcome)
        }

        @Test("canProceed should return true at welcome step")
        func testCanProceedFromWelcome() {
            // Arrange
            let state = OnboardingState()

            // Act
            let canProceed = state.canProceed()

            // Assert
            #expect(canProceed == true)
        }

        @Test("canProceed should return false when name is empty at userType step")
        func testCannotProceedWithoutName() {
            // Arrange
            var state = OnboardingState()
            state.currentStep = .userType
            state.userProfile.name = ""

            // Act
            let canProceed = state.canProceed()

            // Assert
            #expect(canProceed == false)
        }

        @Test("canProceed should return true when name is set at userType step")
        func testCanProceedWithName() {
            // Arrange
            var state = OnboardingState()
            state.currentStep = .userType
            state.userProfile.name = "Test User"

            // Act
            let canProceed = state.canProceed()

            // Assert
            #expect(canProceed == true)
        }

        @Test("canProceed should return true at specialNeeds step")
        func testCanProceedFromSpecialNeeds() {
            // Arrange
            var state = OnboardingState()
            state.currentStep = .specialNeeds

            // Act
            let canProceed = state.canProceed()

            // Assert
            #expect(canProceed == true)
        }

        @Test("canProceed should return true at featureIntro step")
        func testCanProceedFromFeatureIntro() {
            // Arrange
            var state = OnboardingState()
            state.currentStep = .featureIntro

            // Act
            let canProceed = state.canProceed()

            // Assert
            #expect(canProceed == true)
        }

        @Test("canProceed should return true at complete step")
        func testCanProceedFromComplete() {
            // Arrange
            var state = OnboardingState()
            state.currentStep = .complete
            state.userProfile.name = "Test"

            // Act
            let canProceed = state.canProceed()

            // Assert
            #expect(canProceed == true)
        }

        @Test("isCompleted should be false initially")
        func testIsCompletedInitially() {
            // Arrange
            let state = OnboardingState()

            // Assert
            #expect(state.isCompleted == false)
        }

        @Test("isCompleted should be settable")
        func testSetIsCompleted() {
            // Arrange
            var state = OnboardingState()

            // Act
            state.isCompleted = true

            // Assert
            #expect(state.isCompleted == true)
        }

        @Test("Complete onboarding flow should reach complete step")
        func testCompleteOnboardingFlow() {
            // Arrange
            var state = OnboardingState()
            state.userProfile.name = "Test User"
            state.userProfile.userType = .female

            // Act - Progress through all steps
            while state.currentStep != .complete {
                if state.canProceed() {
                    state.nextStep()
                } else {
                    break
                }
            }

            // Assert
            #expect(state.currentStep == .complete)
        }

        @Test("Should be able to go back and forth between steps")
        func testBackAndForth() {
            // Arrange
            var state = OnboardingState()
            state.userProfile.name = "Test"

            // Act
            state.nextStep() // to userType
            state.nextStep() // to specialNeeds
            #expect(state.currentStep == .specialNeeds)

            state.previousStep() // back to userType
            #expect(state.currentStep == .userType)

            state.nextStep() // forward to specialNeeds
            #expect(state.currentStep == .specialNeeds)

            // Assert
            #expect(state.currentStep == .specialNeeds)
        }
    }
}
