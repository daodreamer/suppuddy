//
//  IntakeRecordViewModelTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("IntakeRecordViewModel Tests")
struct IntakeRecordViewModelTests {

    // MARK: - Initialization Tests

    @Suite("Initialization Tests")
    struct InitializationTests {

        @MainActor
        @Test("IntakeRecordViewModel initializes with default values")
        func testDefaultValues() throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let viewModel = IntakeRecordViewModel(
                modelContext: context,
                intakeService: IntakeService()
            )

            #expect(viewModel.availableSupplements.isEmpty)
            #expect(viewModel.todayRecords.isEmpty)
            #expect(viewModel.selectedSupplement == nil)
            #expect(viewModel.selectedTimeOfDay == .morning)
            #expect(viewModel.servingsToRecord == 1)
            #expect(viewModel.isLoading == false)
            #expect(viewModel.errorMessage == nil)
        }
    }

    // MARK: - Load Data Tests

    @Suite("Load Data Tests")
    struct LoadDataTests {

        @MainActor
        @Test("loadData loads available supplements")
        func testLoadDataLoadsSupplements() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            // Create some supplements
            let supplement1 = Supplement(name: "Vitamin C", servingSize: "1 tablet", isActive: true)
            let supplement2 = Supplement(name: "Vitamin D", servingSize: "1 capsule", isActive: true)
            let supplement3 = Supplement(name: "Inactive", servingSize: "1 pill", isActive: false)

            context.insert(supplement1)
            context.insert(supplement2)
            context.insert(supplement3)
            try context.save()

            let viewModel = IntakeRecordViewModel(
                modelContext: context,
                intakeService: IntakeService()
            )

            await viewModel.loadData()

            // Should only load active supplements
            #expect(viewModel.availableSupplements.count == 2)
        }

        @MainActor
        @Test("loadData loads today's records")
        func testLoadDataLoadsTodayRecords() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            // Create today's record
            let today = Date()
            let record = IntakeRecord(
                supplementName: "Vitamin C",
                date: today,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            context.insert(record)
            try context.save()

            let viewModel = IntakeRecordViewModel(
                modelContext: context,
                intakeService: IntakeService()
            )

            await viewModel.loadData()

            #expect(viewModel.todayRecords.count == 1)
        }
    }

    // MARK: - Record Intake Tests

    @Suite("Record Intake Tests")
    struct RecordIntakeTests {

        @MainActor
        @Test("recordIntake creates new intake record")
        func testRecordIntake() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let supplement = Supplement(
                name: "Vitamin C",
                servingSize: "1 tablet",
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )
            context.insert(supplement)
            try context.save()

            let viewModel = IntakeRecordViewModel(
                modelContext: context,
                intakeService: IntakeService()
            )

            await viewModel.loadData()
            viewModel.selectedSupplement = supplement
            viewModel.servingsToRecord = 2
            viewModel.selectedTimeOfDay = .evening

            await viewModel.recordIntake()

            #expect(viewModel.todayRecords.count == 1)
            #expect(viewModel.todayRecords.first?.servingsTaken == 2)
            #expect(viewModel.todayRecords.first?.timeOfDay == .evening)
        }

        @MainActor
        @Test("recordIntake resets selection after recording")
        func testRecordIntakeResetsSelection() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let supplement = Supplement(name: "Vitamin C", servingSize: "1 tablet")
            context.insert(supplement)
            try context.save()

            let viewModel = IntakeRecordViewModel(
                modelContext: context,
                intakeService: IntakeService()
            )

            await viewModel.loadData()
            viewModel.selectedSupplement = supplement
            viewModel.servingsToRecord = 3

            await viewModel.recordIntake()

            #expect(viewModel.selectedSupplement == nil)
            #expect(viewModel.servingsToRecord == 1)
        }
    }

    // MARK: - Delete Record Tests

    @Suite("Delete Record Tests")
    struct DeleteRecordTests {

        @MainActor
        @Test("deleteRecord removes record from list")
        func testDeleteRecord() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, UserProfile.self, configurations: config)
            let context = ModelContext(container)

            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            context.insert(record)
            try context.save()

            let viewModel = IntakeRecordViewModel(
                modelContext: context,
                intakeService: IntakeService()
            )

            await viewModel.loadData()
            #expect(viewModel.todayRecords.count == 1)

            await viewModel.deleteRecord(viewModel.todayRecords.first!)

            #expect(viewModel.todayRecords.isEmpty)
        }
    }
}
