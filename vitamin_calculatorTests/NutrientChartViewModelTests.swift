//
//  NutrientChartViewModelTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("NutrientChartViewModel Tests")
struct NutrientChartViewModelTests {

    @Suite("Initialization Tests")
    struct InitializationTests {

        @MainActor
        @Test("NutrientChartViewModel initializes with default values")
        func testDefaultValues() throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let viewModel = NutrientChartViewModel(modelContext: context)

            #expect(viewModel.selectedNutrient == nil)
            #expect(viewModel.selectedTimeRange == .week)
            #expect(viewModel.chartData.isEmpty)
            #expect(viewModel.averageValue == 0)
            #expect(viewModel.recommendedValue == 0)
            #expect(viewModel.isLoading == false)
        }
    }

    @Suite("Load Chart Data Tests")
    struct LoadChartDataTests {

        @MainActor
        @Test("loadChartData generates data points for selected nutrient")
        func testLoadChartData() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            // Create user profile
            let user = UserProfile(name: "Test", userType: .male)
            context.insert(user)

            // Create records for past week
            for i in 0..<7 {
                let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
                let record = IntakeRecord(
                    supplementName: "Vitamin C",
                    date: date,
                    timeOfDay: .morning,
                    servingsTaken: 1,
                    nutrients: [Nutrient(type: .vitaminC, amount: Double(100 + i * 10))]
                )
                context.insert(record)
            }
            try context.save()

            let viewModel = NutrientChartViewModel(modelContext: context)
            viewModel.selectedNutrient = .vitaminC

            await viewModel.loadChartData()

            #expect(viewModel.chartData.count == 7)
            #expect(viewModel.averageValue > 0)
        }
    }

    @Suite("Time Range Tests")
    struct TimeRangeTests {

        @MainActor
        @Test("changeTimeRange updates time range and reloads data")
        func testChangeTimeRange() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let user = UserProfile(name: "Test", userType: .male)
            context.insert(user)
            try context.save()

            let viewModel = NutrientChartViewModel(modelContext: context)
            viewModel.selectedNutrient = .vitaminC

            #expect(viewModel.selectedTimeRange == .week)

            await viewModel.changeTimeRange(.month)

            #expect(viewModel.selectedTimeRange == .month)
        }
    }

    @Suite("Select Nutrient Tests")
    struct SelectNutrientTests {

        @MainActor
        @Test("selectNutrient updates selection and reloads data")
        func testSelectNutrient() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let user = UserProfile(name: "Test", userType: .male)
            context.insert(user)
            try context.save()

            let viewModel = NutrientChartViewModel(modelContext: context)

            #expect(viewModel.selectedNutrient == nil)

            await viewModel.selectNutrient(.vitaminD)

            #expect(viewModel.selectedNutrient == .vitaminD)
        }
    }
}
