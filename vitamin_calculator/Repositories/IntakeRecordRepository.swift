//
//  IntakeRecordRepository.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import SwiftData

/// Repository for managing IntakeRecord data persistence using SwiftData.
/// Provides CRUD operations and specialized queries for intake records.
@MainActor
final class IntakeRecordRepository {

    // MARK: - Properties

    private let modelContext: ModelContext

    // MARK: - Initialization

    /// Creates a new intake record repository with the specified model context
    /// - Parameter modelContext: The SwiftData model context to use for persistence
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Create

    /// Saves an intake record to the database
    /// - Parameter record: The intake record to save
    /// - Throws: SwiftData errors if save fails
    func save(_ record: IntakeRecord) async throws {
        modelContext.insert(record)
        try modelContext.save()
    }

    // MARK: - Read

    /// Retrieves all intake records from the database
    /// Sprint 7 Phase 1: Optimized with sorting for better performance
    /// - Returns: Array of all intake records, sorted by date (newest first)
    /// - Throws: SwiftData errors if fetch fails
    func getAll() async throws -> [IntakeRecord] {
        var descriptor = FetchDescriptor<IntakeRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        // Performance optimization: Limit result set if needed
        // descriptor.fetchLimit = 1000
        return try modelContext.fetch(descriptor)
    }

    /// Retrieves intake records for a specific date
    /// - Parameter date: The date to query
    /// - Returns: Array of intake records for that date
    /// - Throws: SwiftData errors if fetch fails
    func getByDate(_ date: Date) async throws -> [IntakeRecord] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<IntakeRecord>(
            predicate: #Predicate<IntakeRecord> { record in
                record.date >= startOfDay && record.date < endOfDay
            }
        )
        return try modelContext.fetch(descriptor)
    }

    /// Retrieves intake records within a date range (inclusive)
    /// - Parameters:
    ///   - from: Start date of the range
    ///   - to: End date of the range
    /// - Returns: Array of intake records within the date range
    /// - Throws: SwiftData errors if fetch fails
    func getByDateRange(from: Date, to: Date) async throws -> [IntakeRecord] {
        let calendar = Calendar.current
        let startOfFromDay = calendar.startOfDay(for: from)
        let endOfToDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: to))!

        let descriptor = FetchDescriptor<IntakeRecord>(
            predicate: #Predicate<IntakeRecord> { record in
                record.date >= startOfFromDay && record.date < endOfToDay
            }
        )
        return try modelContext.fetch(descriptor)
    }

    /// Retrieves intake records for a specific supplement
    /// - Parameter supplement: The supplement to query
    /// - Returns: Array of intake records for that supplement
    /// - Throws: SwiftData errors if fetch fails
    func getBySupplement(_ supplement: Supplement) async throws -> [IntakeRecord] {
        let descriptor = FetchDescriptor<IntakeRecord>()
        let allRecords = try modelContext.fetch(descriptor)

        return allRecords.filter { record in
            record.supplement?.persistentModelID == supplement.persistentModelID
        }
    }

    /// Returns the total count of intake records
    /// - Returns: Number of records in the database
    /// - Throws: SwiftData errors if fetch fails
    func count() async throws -> Int {
        let descriptor = FetchDescriptor<IntakeRecord>()
        return try modelContext.fetchCount(descriptor)
    }

    // MARK: - Update

    /// Updates an existing intake record
    /// - Parameter record: The intake record to update
    /// - Throws: SwiftData errors if update fails
    func update(_ record: IntakeRecord) async throws {
        try modelContext.save()
    }

    // MARK: - Delete

    /// Deletes an intake record from the database
    /// - Parameter record: The intake record to delete
    /// - Throws: SwiftData errors if delete fails
    func delete(_ record: IntakeRecord) async throws {
        modelContext.delete(record)
        try modelContext.save()
    }

    /// Deletes all intake records for a specific date
    /// Sprint 7 Phase 1: Optimized batch deletion
    /// - Parameter date: The date for which to delete records
    /// - Throws: SwiftData errors if delete fails
    func deleteByDate(_ date: Date) async throws {
        let recordsToDelete = try await getByDate(date)

        // Disable autosave for batch operations
        modelContext.autosaveEnabled = false

        for record in recordsToDelete {
            modelContext.delete(record)
        }

        // Save once after all deletes
        try modelContext.save()
        modelContext.autosaveEnabled = true
    }

    /// Deletes all intake records from the database
    /// Sprint 7 Phase 1: Optimized batch deletion
    /// - Throws: SwiftData errors if delete fails
    func deleteAll() async throws {
        let descriptor = FetchDescriptor<IntakeRecord>()
        let allRecords = try modelContext.fetch(descriptor)

        // Disable autosave for batch operations
        modelContext.autosaveEnabled = false

        for record in allRecords {
            modelContext.delete(record)
        }

        // Save once after all deletes
        try modelContext.save()
        modelContext.autosaveEnabled = true
    }
}
