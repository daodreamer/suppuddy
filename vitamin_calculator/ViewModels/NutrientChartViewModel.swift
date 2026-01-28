//
//  NutrientChartViewModel.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import SwiftData
import Observation

/// Time range options for chart display
enum TimeRange: String, CaseIterable {
    case week
    case month
    case threeMonths

    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        }
    }

    var displayName: String {
        switch self {
        case .week: return "7天"
        case .month: return "30天"
        case .threeMonths: return "90天"
        }
    }
}

/// ViewModel for the Nutrient Chart view, managing chart data and visualization settings.
@MainActor
@Observable
final class NutrientChartViewModel {

    // MARK: - Published Properties

    /// Currently selected nutrient for display
    var selectedNutrient: NutrientType?

    /// Selected time range for the chart
    var selectedTimeRange: TimeRange = .week

    /// Data points for the chart
    var chartData: [DataPoint] = []

    /// Average value across the time range
    var averageValue: Double = 0

    /// Recommended daily value for the selected nutrient
    var recommendedValue: Double = 0

    /// Loading state indicator
    var isLoading: Bool = false

    /// Error message if operation fails
    var errorMessage: String?

    // MARK: - Private Properties

    private let modelContext: ModelContext
    private let intakeRecordRepository: IntakeRecordRepository
    private let intakeService: IntakeService

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.intakeRecordRepository = IntakeRecordRepository(modelContext: modelContext)
        self.intakeService = IntakeService()
    }

    // MARK: - Public Methods

    /// Loads chart data for the selected nutrient and time range
    func loadChartData() async {
        guard let nutrient = selectedNutrient else { return }

        isLoading = true
        errorMessage = nil

        do {
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -(selectedTimeRange.days - 1), to: endDate)!

            let records = try await intakeRecordRepository.getByDateRange(from: startDate, to: endDate)

            // Get user profile for recommendations
            let user = try fetchUserProfile()

            // Generate trend data
            let trend = intakeService.getWeeklyTrend(endingOn: endDate, records: records)

            // Get data points for the selected nutrient
            chartData = trend.dataPoints(for: nutrient)

            // Calculate average
            averageValue = trend.averageIntake(for: nutrient)

            // Get recommended value
            if let recommendation = DGERecommendations.getRecommendation(for: nutrient, userType: user.userType) {
                recommendedValue = recommendation.recommendedAmount
            }

            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    /// Selects a nutrient and reloads chart data
    func selectNutrient(_ nutrient: NutrientType) async {
        selectedNutrient = nutrient
        await loadChartData()
    }

    /// Changes the time range and reloads chart data
    func changeTimeRange(_ range: TimeRange) async {
        selectedTimeRange = range
        await loadChartData()
    }

    // MARK: - Private Methods

    private func fetchUserProfile() throws -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(descriptor)

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
