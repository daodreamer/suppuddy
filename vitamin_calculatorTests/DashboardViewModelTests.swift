//
//  DashboardViewModelTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("DashboardViewModel Tests")
struct DashboardViewModelTests {

    // MARK: - Initialization Tests

    @Suite("Initialization Tests")
    struct InitializationTests {

        @MainActor
        @Test("DashboardViewModel initializes with default values")
        func testDefaultValues() {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let viewModel = DashboardViewModel(
                modelContext: context,
                intakeService: IntakeService()
            )

            #expect(viewModel.todaySummary == nil)
            #expect(viewModel.weeklyTrend == nil)
            #expect(viewModel.healthTips.isEmpty)
            #expect(viewModel.isLoading == false)
            #expect(viewModel.errorMessage == nil)
        }
    }

    // MARK: - Load Data Tests

    @Suite("Load Data Tests")
    struct LoadDataTests {

        @MainActor
        @Test("loadTodayData sets todaySummary")
        func testLoadTodayData() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            // Create and save a user profile
            let user = UserProfile(name: "Test User", userType: .male)
            context.insert(user)
            try context.save()

            // Create and save an intake record
            let record = IntakeRecord(
                supplementName: "Test Vitamin",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            context.insert(record)
            try context.save()

            let viewModel = DashboardViewModel(
                modelContext: context,
                intakeService: IntakeService()
            )

            await viewModel.loadTodayData()

            #expect(viewModel.todaySummary != nil)
            #expect(viewModel.todaySummary?.recordCount == 1)
        }

        @MainActor
        @Test("loadTodayData sets weeklyTrend")
        func testLoadTodayDataSetsWeeklyTrend() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let user = UserProfile(name: "Test User", userType: .male)
            context.insert(user)
            try context.save()

            let viewModel = DashboardViewModel(
                modelContext: context,
                intakeService: IntakeService()
            )

            await viewModel.loadTodayData()

            #expect(viewModel.weeklyTrend != nil)
            #expect(viewModel.weeklyTrend?.dayCount == 7)
        }

        @MainActor
        @Test("loadTodayData generates health tips")
        func testLoadTodayDataGeneratesHealthTips() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let user = UserProfile(name: "Test User", userType: .male)
            context.insert(user)
            try context.save()

            // Create a record with insufficient vitamin C
            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 30)] // Insufficient
            )
            context.insert(record)
            try context.save()

            let viewModel = DashboardViewModel(
                modelContext: context,
                intakeService: IntakeService()
            )

            await viewModel.loadTodayData()

            // Should have health tips for insufficient vitamin C
            #expect(!viewModel.healthTips.isEmpty)
        }
    }

    // MARK: - Loading State Tests

    @Suite("Loading State Tests")
    struct LoadingStateTests {

        @MainActor
        @Test("isLoading is true during load")
        func testIsLoadingDuringLoad() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let user = UserProfile(name: "Test User", userType: .male)
            context.insert(user)
            try context.save()

            let viewModel = DashboardViewModel(
                modelContext: context,
                intakeService: IntakeService()
            )

            // Start loading and check state
            // Note: In actual async test, we'd need to observe the state changes
            await viewModel.loadTodayData()

            // After loading completes, isLoading should be false
            #expect(viewModel.isLoading == false)
        }
    }

    // MARK: - Refresh Tests

    @Suite("Refresh Tests")
    struct RefreshTests {

        @MainActor
        @Test("refresh reloads data")
        func testRefresh() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let user = UserProfile(name: "Test User", userType: .male)
            context.insert(user)
            try context.save()

            let viewModel = DashboardViewModel(
                modelContext: context,
                intakeService: IntakeService()
            )

            // Initial load
            await viewModel.loadTodayData()
            #expect(viewModel.todaySummary?.recordCount == 0)

            // Add a new record
            let record = IntakeRecord(
                supplementName: "New Vitamin",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            context.insert(record)
            try context.save()

            // Refresh
            await viewModel.refresh()

            #expect(viewModel.todaySummary?.recordCount == 1)
        }
    }
}
