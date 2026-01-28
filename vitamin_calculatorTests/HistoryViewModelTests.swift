//
//  HistoryViewModelTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("HistoryViewModel Tests")
struct HistoryViewModelTests {

    @Suite("Initialization Tests")
    struct InitializationTests {

        @MainActor
        @Test("HistoryViewModel initializes with default values")
        func testDefaultValues() throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let viewModel = HistoryViewModel(modelContext: context)

            #expect(viewModel.records.isEmpty)
            #expect(viewModel.isLoading == false)
            #expect(viewModel.errorMessage == nil)
        }
    }

    @Suite("Load Records Tests")
    struct LoadRecordsTests {

        @MainActor
        @Test("loadRecords for date loads records for that day")
        func testLoadRecordsForDate() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

            let todayRecord = IntakeRecord(
                supplementName: "Today",
                date: today,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            let yesterdayRecord = IntakeRecord(
                supplementName: "Yesterday",
                date: yesterday,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )

            context.insert(todayRecord)
            context.insert(yesterdayRecord)
            try context.save()

            let viewModel = HistoryViewModel(modelContext: context)
            await viewModel.loadRecords(for: today)

            #expect(viewModel.records.count == 1)
            #expect(viewModel.records.first?.supplementName == "Today")
        }

        @MainActor
        @Test("loadRecords for date range loads records within range")
        func testLoadRecordsForDateRange() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today)!

            let todayRecord = IntakeRecord(supplementName: "Today", date: today, timeOfDay: .morning, servingsTaken: 1, nutrients: [])
            let yesterdayRecord = IntakeRecord(supplementName: "Yesterday", date: yesterday, timeOfDay: .morning, servingsTaken: 1, nutrients: [])
            let weekAgoRecord = IntakeRecord(supplementName: "Week Ago", date: weekAgo, timeOfDay: .morning, servingsTaken: 1, nutrients: [])

            context.insert(todayRecord)
            context.insert(yesterdayRecord)
            context.insert(weekAgoRecord)
            try context.save()

            let viewModel = HistoryViewModel(modelContext: context)
            await viewModel.loadRecords(from: yesterday, to: today)

            #expect(viewModel.records.count == 2)
        }
    }

    @Suite("Calendar Data Tests")
    struct CalendarDataTests {

        @MainActor
        @Test("loadCalendarData generates intake status for month")
        func testLoadCalendarData() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let today = Date()
            let record = IntakeRecord(
                supplementName: "Test",
                date: today,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            context.insert(record)
            try context.save()

            let viewModel = HistoryViewModel(modelContext: context)
            await viewModel.loadCalendarData(for: today)

            // Should have calendar data for the month
            #expect(!viewModel.calendarData.isEmpty)
        }
    }
}
