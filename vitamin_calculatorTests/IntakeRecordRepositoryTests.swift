//
//  IntakeRecordRepositoryTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("IntakeRecordRepository Tests")
struct IntakeRecordRepositoryTests {

    // MARK: - Save Tests

    @Suite("Save Tests")
    struct SaveTests {

        @MainActor
        @Test("Save a single record successfully")
        func testSaveSingle() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let record = IntakeRecord(
                supplementName: "Vitamin C",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: [Nutrient(type: .vitaminC, amount: 100)]
            )

            try await repository.save(record)

            let fetched = try await repository.getAll()
            #expect(fetched.count == 1)
            #expect(fetched.first?.supplementName == "Vitamin C")
        }

        @MainActor
        @Test("Save multiple records successfully")
        func testSaveMultiple() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let record1 = IntakeRecord(
                supplementName: "Vitamin C",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            let record2 = IntakeRecord(
                supplementName: "Vitamin D",
                date: Date(),
                timeOfDay: .evening,
                servingsTaken: 1,
                nutrients: []
            )

            try await repository.save(record1)
            try await repository.save(record2)

            let fetched = try await repository.getAll()
            #expect(fetched.count == 2)
        }
    }

    // MARK: - Fetch Tests

    @Suite("Fetch Tests")
    struct FetchTests {

        @MainActor
        @Test("Get all records returns empty array when none exist")
        func testGetAllEmpty() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let fetched = try await repository.getAll()
            #expect(fetched.isEmpty)
        }

        @MainActor
        @Test("Get all records returns all saved records")
        func testGetAllReturnsAll() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            for i in 1...5 {
                let record = IntakeRecord(
                    supplementName: "Supplement \(i)",
                    date: Date(),
                    timeOfDay: .morning,
                    servingsTaken: 1,
                    nutrients: []
                )
                try await repository.save(record)
            }

            let fetched = try await repository.getAll()
            #expect(fetched.count == 5)
        }
    }

    // MARK: - Query by Date Tests

    @Suite("Query by Date Tests")
    struct QueryByDateTests {

        @MainActor
        @Test("Get records by specific date")
        func testGetByDate() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

            // Save records for today
            let record1 = IntakeRecord(
                supplementName: "Today Record 1",
                date: today,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            let record2 = IntakeRecord(
                supplementName: "Today Record 2",
                date: today,
                timeOfDay: .evening,
                servingsTaken: 1,
                nutrients: []
            )

            // Save record for yesterday
            let record3 = IntakeRecord(
                supplementName: "Yesterday Record",
                date: yesterday,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )

            try await repository.save(record1)
            try await repository.save(record2)
            try await repository.save(record3)

            let todayRecords = try await repository.getByDate(today)

            #expect(todayRecords.count == 2)
            #expect(todayRecords.allSatisfy { Calendar.current.isDate($0.date, inSameDayAs: today) })
        }

        @MainActor
        @Test("Get records returns empty for date with no records")
        func testGetByDateEmpty() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

            let record = IntakeRecord(
                supplementName: "Yesterday",
                date: yesterday,
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            try await repository.save(record)

            let todayRecords = try await repository.getByDate(today)
            #expect(todayRecords.isEmpty)
        }
    }

    // MARK: - Query by Date Range Tests

    @Suite("Query by Date Range Tests")
    struct QueryByDateRangeTests {

        @MainActor
        @Test("Get records by date range")
        func testGetByDateRange() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today)!

            // Record within range
            let record1 = IntakeRecord(supplementName: "Yesterday", date: yesterday, timeOfDay: .morning, servingsTaken: 1, nutrients: [])
            let record2 = IntakeRecord(supplementName: "Two Days Ago", date: twoDaysAgo, timeOfDay: .morning, servingsTaken: 1, nutrients: [])

            // Record outside range
            let record3 = IntakeRecord(supplementName: "Week Ago", date: weekAgo, timeOfDay: .morning, servingsTaken: 1, nutrients: [])

            try await repository.save(record1)
            try await repository.save(record2)
            try await repository.save(record3)

            let rangeRecords = try await repository.getByDateRange(from: twoDaysAgo, to: today)

            #expect(rangeRecords.count == 2)
        }

        @MainActor
        @Test("Get records by date range includes boundary dates")
        func testGetByDateRangeIncludesBoundaries() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let today = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -3, to: today)!

            let record1 = IntakeRecord(supplementName: "Start", date: startDate, timeOfDay: .morning, servingsTaken: 1, nutrients: [])
            let record2 = IntakeRecord(supplementName: "End", date: today, timeOfDay: .morning, servingsTaken: 1, nutrients: [])

            try await repository.save(record1)
            try await repository.save(record2)

            let rangeRecords = try await repository.getByDateRange(from: startDate, to: today)

            #expect(rangeRecords.count == 2)
        }
    }

    // MARK: - Query by Supplement Tests

    @Suite("Query by Supplement Tests")
    struct QueryBySupplementTests {

        @MainActor
        @Test("Get records by supplement")
        func testGetBySupplement() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let supplement = Supplement(name: "Vitamin C", servingSize: "1 tablet")
            context.insert(supplement)
            try context.save()

            let record1 = IntakeRecord(
                supplement: supplement,
                supplementName: supplement.name,
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            let record2 = IntakeRecord(
                supplement: supplement,
                supplementName: supplement.name,
                date: Date(),
                timeOfDay: .evening,
                servingsTaken: 1,
                nutrients: []
            )
            let record3 = IntakeRecord(
                supplementName: "Other Supplement",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )

            try await repository.save(record1)
            try await repository.save(record2)
            try await repository.save(record3)

            let supplementRecords = try await repository.getBySupplement(supplement)

            #expect(supplementRecords.count == 2)
        }
    }

    // MARK: - Update Tests

    @Suite("Update Tests")
    struct UpdateTests {

        @MainActor
        @Test("Update record servings")
        func testUpdateServings() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            try await repository.save(record)

            record.servingsTaken = 2
            try await repository.update(record)

            let fetched = try await repository.getAll()
            #expect(fetched.first?.servingsTaken == 2)
        }

        @MainActor
        @Test("Update record notes")
        func testUpdateNotes() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let record = IntakeRecord(
                supplementName: "Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            try await repository.save(record)

            record.notes = "Updated notes"
            try await repository.update(record)

            let fetched = try await repository.getAll()
            #expect(fetched.first?.notes == "Updated notes")
        }
    }

    // MARK: - Delete Tests

    @Suite("Delete Tests")
    struct DeleteTests {

        @MainActor
        @Test("Delete a single record")
        func testDeleteSingle() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let record = IntakeRecord(
                supplementName: "To Delete",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            try await repository.save(record)

            try await repository.delete(record)

            let fetched = try await repository.getAll()
            #expect(fetched.isEmpty)
        }

        @MainActor
        @Test("Delete one of multiple records")
        func testDeleteOneOfMany() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let record1 = IntakeRecord(supplementName: "Keep", date: Date(), timeOfDay: .morning, servingsTaken: 1, nutrients: [])
            let record2 = IntakeRecord(supplementName: "Delete", date: Date(), timeOfDay: .evening, servingsTaken: 1, nutrients: [])

            try await repository.save(record1)
            try await repository.save(record2)

            try await repository.delete(record2)

            let fetched = try await repository.getAll()
            #expect(fetched.count == 1)
            #expect(fetched.first?.supplementName == "Keep")
        }

        @MainActor
        @Test("Delete by date removes all records for that date")
        func testDeleteByDate() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let today = Date()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

            let record1 = IntakeRecord(supplementName: "Today 1", date: today, timeOfDay: .morning, servingsTaken: 1, nutrients: [])
            let record2 = IntakeRecord(supplementName: "Today 2", date: today, timeOfDay: .evening, servingsTaken: 1, nutrients: [])
            let record3 = IntakeRecord(supplementName: "Yesterday", date: yesterday, timeOfDay: .morning, servingsTaken: 1, nutrients: [])

            try await repository.save(record1)
            try await repository.save(record2)
            try await repository.save(record3)

            try await repository.deleteByDate(today)

            let fetched = try await repository.getAll()
            #expect(fetched.count == 1)
            #expect(fetched.first?.supplementName == "Yesterday")
        }
    }

    // MARK: - Count Tests

    @Suite("Count Tests")
    struct CountTests {

        @MainActor
        @Test("Count returns correct number of records")
        func testCount() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            for i in 1...3 {
                let record = IntakeRecord(
                    supplementName: "Record \(i)",
                    date: Date(),
                    timeOfDay: .morning,
                    servingsTaken: 1,
                    nutrients: []
                )
                try await repository.save(record)
            }

            let count = try await repository.count()
            #expect(count == 3)
        }

        @MainActor
        @Test("Count returns 0 for empty repository")
        func testCountEmpty() async throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: IntakeRecord.self, Supplement.self, configurations: config)
            let context = ModelContext(container)
            let repository = IntakeRecordRepository(modelContext: context)

            let count = try await repository.count()
            #expect(count == 0)
        }
    }
}
