//
//  ScanHistoryRepository.swift
//  vitamin_calculator
//
//  Created by TDD on 26.01.26.
//

import Foundation
import SwiftData

/// Repository for managing ScanHistory data persistence using SwiftData.
/// Provides CRUD operations for scan history with automatic pruning.
@MainActor
final class ScanHistoryRepository {

    // MARK: - Properties

    private let modelContext: ModelContext
    private let maxHistoryCount = 20

    // MARK: - Initialization

    /// Creates a new scan history repository with the specified model context
    /// - Parameter modelContext: The SwiftData model context to use for persistence
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Create

    /// Saves a scan history record to the database
    /// - Parameter history: The scan history to save
    /// - Throws: SwiftData errors if save fails
    func save(_ history: ScanHistory) async throws {
        modelContext.insert(history)
        try modelContext.save()
    }

    // MARK: - Read

    /// Retrieves all scan history records from the database
    /// - Returns: Array of all scan history records
    /// - Throws: SwiftData errors if fetch fails
    func getAll() async throws -> [ScanHistory] {
        let descriptor = FetchDescriptor<ScanHistory>()
        return try modelContext.fetch(descriptor)
    }

    /// Retrieves the most recent N scan history records
    /// - Parameter limit: Maximum number of records to return
    /// - Returns: Array of recent scan history records, sorted by scannedAt descending
    /// - Throws: SwiftData errors if fetch fails
    func getRecent(limit: Int) async throws -> [ScanHistory] {
        // Handle zero limit edge case
        guard limit > 0 else {
            return []
        }

        var descriptor = FetchDescriptor<ScanHistory>(
            sortBy: [SortDescriptor(\.scannedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }

    /// Retrieves a scan history record by barcode
    /// Returns the most recent record if multiple exist for the same barcode
    /// - Parameter barcode: The barcode to search for
    /// - Returns: The most recent scan history for the barcode, or nil if not found
    /// - Throws: SwiftData errors if fetch fails
    func getByBarcode(_ barcode: String) async throws -> ScanHistory? {
        var descriptor = FetchDescriptor<ScanHistory>(
            predicate: #Predicate { $0.barcode == barcode },
            sortBy: [SortDescriptor(\.scannedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    // MARK: - Delete

    /// Deletes a scan history record from the database
    /// - Parameter history: The scan history to delete
    /// - Throws: SwiftData errors if delete fails
    func delete(_ history: ScanHistory) async throws {
        modelContext.delete(history)
        try modelContext.save()
    }

    /// Clears all scan history records from the database
    /// - Throws: SwiftData errors if delete fails
    func clearAll() async throws {
        let descriptor = FetchDescriptor<ScanHistory>()
        let allHistory = try modelContext.fetch(descriptor)
        for history in allHistory {
            modelContext.delete(history)
        }
        try modelContext.save()
    }

    /// Prunes old scan history entries, keeping only the most recent N records
    /// where N is defined by maxHistoryCount (default 20)
    /// - Throws: SwiftData errors if operation fails
    func pruneOldEntries() async throws {
        let descriptor = FetchDescriptor<ScanHistory>(
            sortBy: [SortDescriptor(\.scannedAt, order: .reverse)]
        )
        let allHistory = try modelContext.fetch(descriptor)

        // If we have more than the max count, delete the oldest ones
        if allHistory.count > maxHistoryCount {
            let toDelete = allHistory.suffix(allHistory.count - maxHistoryCount)
            for history in toDelete {
                modelContext.delete(history)
            }
            try modelContext.save()
        }
    }
}
