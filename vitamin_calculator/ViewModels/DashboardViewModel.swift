//
//  DashboardViewModel.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import SwiftData
import Observation

/// ViewModel for the Dashboard view, managing today's intake summary and health tips.
@MainActor
@Observable
final class DashboardViewModel {

    // MARK: - Published Properties

    /// Today's intake summary
    var todaySummary: DailyIntakeSummary?

    /// Weekly trend data for charts
    var weeklyTrend: WeeklyTrend?

    /// Health tips based on current intake
    var healthTips: [HealthTip] = []

    /// Loading state indicator
    var isLoading: Bool = false

    /// Error message if loading fails
    var errorMessage: String?

    // MARK: - Private Properties

    private let modelContext: ModelContext
    private let intakeService: IntakeService
    private let intakeRecordRepository: IntakeRecordRepository

    // MARK: - Initialization

    /// Creates a new dashboard view model
    /// - Parameters:
    ///   - modelContext: The SwiftData model context
    ///   - intakeService: The intake service for business logic
    init(modelContext: ModelContext, intakeService: IntakeService) {
        self.modelContext = modelContext
        self.intakeService = intakeService
        self.intakeRecordRepository = IntakeRecordRepository(modelContext: modelContext)
    }

    // MARK: - Public Methods

    /// Loads today's data including summary, weekly trend, and health tips
    func loadTodayData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch all records
            let allRecords = try await intakeRecordRepository.getAll()

            // Get user profile
            let user = try fetchUserProfile()

            // Generate today's summary
            let today = Date()
            todaySummary = intakeService.getDailySummary(for: today, records: allRecords, user: user)

            // Generate weekly trend
            weeklyTrend = intakeService.getWeeklyTrend(endingOn: today, records: allRecords)

            // Generate health tips
            if let summary = todaySummary {
                healthTips = intakeService.generateHealthTips(summary: summary, user: user)
            }

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    /// Refreshes all dashboard data
    func refresh() async {
        await loadTodayData()
    }

    // MARK: - Private Methods

    private func fetchUserProfile() throws -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(descriptor)

        // Return existing profile or create a default one
        if let profile = profiles.first {
            return profile
        } else {
            let defaultProfile = UserProfile(name: "User", userType: .male)
            modelContext.insert(defaultProfile)
            try modelContext.save()
            return defaultProfile
        }
    }
}
