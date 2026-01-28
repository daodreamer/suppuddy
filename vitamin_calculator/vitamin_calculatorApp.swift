//
//  vitamin_calculatorApp.swift
//  vitamin_calculator
//
//  Created by Jiongdao Wang on 25.01.26.
//  Updated: Sprint 7 Phase 1 - Performance Optimization
//

import SwiftUI
import SwiftData
import os.signpost

@main
struct vitamin_calculatorApp: App {
    // MARK: - Performance Monitoring

    private let performanceMonitor = PerformanceMonitor.shared

    // MARK: - SwiftData Model Container

    var modelContainer: ModelContainer = {
        let signpostID = PerformanceMonitor.shared.begin("ModelContainer Init")
        defer { PerformanceMonitor.shared.end("ModelContainer Init", signpostID: signpostID) }

        let schema = Schema([
            UserProfile.self,
            Supplement.self,
            IntakeRecord.self,
            ScanHistory.self  // Added for Sprint 5 - Barcode scanning history
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Onboarding State

    @State private var showOnboarding = false
    @State private var isCheckingOnboarding = true

    // MARK: - Initialization

    init() {
        // Sprint 7 Phase 1: Configure cache on app launch
        CacheConfiguration.configure()
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            Group {
                if isCheckingOnboarding {
                    // Show loading screen while checking onboarding status
                    ProgressView()
                        .scaleEffect(1.5)
                } else if showOnboarding {
                    // Show onboarding for first-time users
                    OnboardingView(
                        onboardingService: createOnboardingService(),
                        onComplete: {
                            showOnboarding = false
                        }
                    )
                } else {
                    // Show main app content
                    ContentView()
                }
            }
            .task {
                await checkOnboardingStatus()
            }
        }
        .modelContainer(modelContainer)
    }

    // MARK: - Private Methods

    /// Checks if the user needs to complete onboarding
    private func checkOnboardingStatus() async {
        let signpostID = performanceMonitor.begin("Onboarding Check")
        defer { performanceMonitor.end("Onboarding Check", signpostID: signpostID) }

        let context = modelContainer.mainContext
        let userRepository = UserRepository(modelContext: context)
        let onboardingService = OnboardingService(userRepository: userRepository)

        do {
            showOnboarding = try await onboardingService.shouldShowOnboarding()
        } catch {
            // If there's an error, don't show onboarding
            // (fail safe to allow user to access the app)
            print("Error checking onboarding status: \(error)")
            showOnboarding = false
        }

        isCheckingOnboarding = false
    }

    /// Creates an onboarding service with the main context
    private func createOnboardingService() -> OnboardingService {
        let context = modelContainer.mainContext
        let userRepository = UserRepository(modelContext: context)
        return OnboardingService(userRepository: userRepository)
    }
}
