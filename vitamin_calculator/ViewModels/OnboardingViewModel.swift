//
//  OnboardingViewModel.swift
//  vitamin_calculator
//
//  Created by Claude Code on 28.01.26.
//

import Foundation
import Observation

/// ViewModel for managing the onboarding flow.
///
/// Responsibilities:
/// - Navigate through onboarding steps
/// - Collect user profile data during onboarding
/// - Validate user input at each step
/// - Complete or skip onboarding process
///
/// Usage:
/// ```swift
/// let viewModel = OnboardingViewModel(onboardingService: service)
/// viewModel.state.userProfile.name = "John"
/// viewModel.nextStep()
/// await viewModel.completeOnboarding()
/// ```
@MainActor
@Observable
final class OnboardingViewModel {

    // MARK: - Published Properties

    /// Current onboarding state containing step and user data.
    /// Directly mutable to allow UI binding.
    var state: OnboardingState

    /// Indicates if an async operation is in progress.
    var isLoading: Bool = false

    /// User-facing error message if operations fail.
    /// Automatically cleared on next navigation action.
    var errorMessage: String?

    // MARK: - Computed Properties

    /// Current step index (0-based).
    /// Use this for progress indicators.
    var currentStepIndex: Int { state.currentStep.rawValue }

    /// Total number of steps in the onboarding flow.
    var totalSteps: Int { OnboardingStep.allCases.count }

    /// Whether navigation to previous step is allowed.
    /// Returns false only at the first step.
    var canGoBack: Bool { currentStepIndex > 0 }

    /// Whether user can proceed from current step.
    /// Delegates to state's validation logic.
    var canProceed: Bool { state.canProceed() }

    /// Whether currently at the final completion step.
    var isLastStep: Bool { state.currentStep == .complete }

    // MARK: - Private Properties

    private let onboardingService: OnboardingService

    // MARK: - Initialization

    /// Creates a new onboarding view model
    /// - Parameter onboardingService: Service for onboarding operations
    init(onboardingService: OnboardingService) {
        self.onboardingService = onboardingService
        self.state = OnboardingState()
    }

    // MARK: - Public Methods

    /// Advances to the next step.
    /// Clears any error messages and updates the state.
    func nextStep() {
        errorMessage = nil
        state.nextStep()
    }

    /// Goes back to the previous step.
    /// Clears any error messages and updates the state.
    func previousStep() {
        errorMessage = nil
        state.previousStep()
    }

    /// Skips the onboarding and creates a default user.
    /// Uses the onboarding service to create a minimal user profile.
    func skipOnboarding() async {
        isLoading = true
        errorMessage = nil

        do {
            try await onboardingService.skipOnboarding()
            state.isCompleted = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Completes the onboarding and creates user profile from collected data.
    /// Validates that required fields are filled before creating the profile.
    func completeOnboarding() async {
        isLoading = true
        errorMessage = nil

        // Validation
        guard !state.userProfile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "请输入您的名称"
            isLoading = false
            return
        }

        do {
            _ = try await onboardingService.completeOnboarding(draft: state.userProfile)
            state.isCompleted = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
