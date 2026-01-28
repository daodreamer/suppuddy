//
//  OnboardingState.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 1.3
//

import Foundation

// MARK: - OnboardingState

/// Manages the state of the onboarding flow
struct OnboardingState {
    /// Current step in the onboarding process
    var currentStep: OnboardingStep

    /// Draft user profile being built during onboarding
    var userProfile: UserProfileDraft

    /// Whether the onboarding has been completed
    var isCompleted: Bool

    // MARK: - Initialization

    /// Creates a new onboarding state starting at the welcome step
    init(userProfile: UserProfileDraft = UserProfileDraft()) {
        self.currentStep = .welcome
        self.userProfile = userProfile
        self.isCompleted = false
    }

    // MARK: - Navigation

    /// Advances to the next step in the onboarding flow
    mutating func nextStep() {
        guard let nextIndex = OnboardingStep.allCases.firstIndex(where: { $0.rawValue == currentStep.rawValue + 1 }) else {
            return // Already at last step
        }
        currentStep = OnboardingStep.allCases[nextIndex]
    }

    /// Goes back to the previous step in the onboarding flow
    mutating func previousStep() {
        guard currentStep.rawValue > 0,
              let prevIndex = OnboardingStep.allCases.firstIndex(where: { $0.rawValue == currentStep.rawValue - 1 }) else {
            return // Already at first step
        }
        currentStep = OnboardingStep.allCases[prevIndex]
    }

    // MARK: - Validation

    /// Checks if the user can proceed from the current step
    /// - Returns: true if validation passes for the current step
    func canProceed() -> Bool {
        switch currentStep {
        case .welcome:
            return true
        case .userType:
            // Require a non-empty name to proceed
            return !userProfile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .specialNeeds:
            return true
        case .featureIntro:
            return true
        case .complete:
            return !userProfile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}

// MARK: - OnboardingStep

/// Represents individual steps in the onboarding process
enum OnboardingStep: Int, CaseIterable {
    /// Welcome screen
    case welcome = 0

    /// User type selection (male/female/child)
    case userType = 1

    /// Special needs selection (pregnancy, breastfeeding)
    case specialNeeds = 2

    /// Feature introduction (app overview)
    case featureIntro = 3

    /// Completion step
    case complete = 4

    // MARK: - Properties

    /// Localized title for this step
    var title: String {
        switch self {
        case .welcome:
            return NSLocalizedString("Welcome", comment: "Onboarding welcome step title")
        case .userType:
            return NSLocalizedString("About You", comment: "Onboarding user type step title")
        case .specialNeeds:
            return NSLocalizedString("Special Needs", comment: "Onboarding special needs step title")
        case .featureIntro:
            return NSLocalizedString("Features", comment: "Onboarding features step title")
        case .complete:
            return NSLocalizedString("All Set!", comment: "Onboarding complete step title")
        }
    }

    /// Localized description for this step
    var description: String {
        switch self {
        case .welcome:
            return NSLocalizedString("Welcome to Vitamin Calculator! Let's set up your profile to get personalized recommendations.", comment: "Onboarding welcome description")
        case .userType:
            return NSLocalizedString("Tell us a bit about yourself so we can provide accurate nutrient recommendations.", comment: "Onboarding user type description")
        case .specialNeeds:
            return NSLocalizedString("Do you have any special nutritional needs?", comment: "Onboarding special needs description")
        case .featureIntro:
            return NSLocalizedString("Here's what you can do with this app:", comment: "Onboarding features description")
        case .complete:
            return NSLocalizedString("You're all set! Start tracking your supplements and nutrients.", comment: "Onboarding complete description")
        }
    }
}

// MARK: - UserProfileDraft

/// Temporary user profile data collected during onboarding
struct UserProfileDraft {
    /// User's name
    var name: String = ""

    /// User's demographic type
    var userType: UserType = .male

    /// User's birth date (optional)
    var birthDate: Date?

    /// Special nutritional needs
    var specialNeeds: SpecialNeeds = .none
}
