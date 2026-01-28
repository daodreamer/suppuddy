//
//  OnboardingView.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 5.1
//

import SwiftUI
import SwiftData

/// Main onboarding view that guides users through initial setup.
/// Displays different steps with progress tracking and navigation controls.
struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    init(onboardingService: OnboardingService, onComplete: @escaping () -> Void) {
        self._viewModel = State(initialValue: OnboardingViewModel(onboardingService: onboardingService))
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: 0) {
            // Skip button at top right
            HStack {
                Spacer()
                if !viewModel.isLastStep {
                    Button("跳过") {
                        Task {
                            await viewModel.skipOnboarding()
                            if viewModel.state.isCompleted {
                                onComplete()
                            }
                        }
                    }
                    .padding()
                }
            }

            // Progress indicator
            ProgressIndicatorView(
                current: viewModel.currentStepIndex,
                total: viewModel.totalSteps
            )
            .padding(.horizontal)
            .padding(.bottom, 20)

            // Current step content
            TabView(selection: Binding(
                get: { viewModel.state.currentStep },
                set: { _ in }
            )) {
                WelcomeStepView()
                    .tag(OnboardingStep.welcome)

                UserTypeStepView(userProfile: $viewModel.state.userProfile)
                    .tag(OnboardingStep.userType)

                SpecialNeedsStepView(specialNeeds: $viewModel.state.userProfile.specialNeeds)
                    .tag(OnboardingStep.specialNeeds)

                FeatureIntroStepView()
                    .tag(OnboardingStep.featureIntro)

                CompleteStepView()
                    .tag(OnboardingStep.complete)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.state.currentStep)

            // Error message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }

            // Navigation buttons
            HStack(spacing: 20) {
                // Back button
                if viewModel.canGoBack && !viewModel.isLastStep {
                    Button(action: {
                        viewModel.previousStep()
                    }) {
                        Label("上一步", systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                // Next/Complete button
                Button(action: {
                    if viewModel.isLastStep {
                        Task {
                            await viewModel.completeOnboarding()
                            if viewModel.state.isCompleted {
                                onComplete()
                            }
                        }
                    } else {
                        viewModel.nextStep()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Label(
                            viewModel.isLastStep ? "完成" : "下一步",
                            systemImage: viewModel.isLastStep ? "checkmark.circle.fill" : "chevron.right"
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canProceed || viewModel.isLoading)
            }
            .padding()
        }
    }
}

// MARK: - Progress Indicator

/// Visual progress indicator showing current step in the onboarding flow.
struct ProgressIndicatorView: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    let context = ModelContext(container)

    let userRepository = UserRepository(modelContext: context)
    let onboardingService = OnboardingService(userRepository: userRepository)

    OnboardingView(onboardingService: onboardingService) {
        print("Onboarding completed")
    }
}
