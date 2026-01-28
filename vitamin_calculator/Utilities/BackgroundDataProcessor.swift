//
//  BackgroundDataProcessor.swift
//  vitamin_calculator
//
//  Created by Claude Code on 28.01.26.
//  Sprint 7 Phase 1: Database Performance Optimization
//

import Foundation
import SwiftData

/// Handles large data operations in the background to avoid blocking the UI
/// Sprint 7 Phase 1: Added for better database performance
actor BackgroundDataProcessor {

    // MARK: - Properties

    private let modelContainer: ModelContainer

    // MARK: - Initialization

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    // MARK: - Batch Operations

    /// Performs a batch data operation in the background
    /// - Parameter operation: The closure containing the batch operation
    /// - Returns: Result of the operation
    /// - Throws: Any error that occurs during the operation
    func performBatchOperation<T>(_ operation: @escaping (ModelContext) throws -> T) async throws -> T {
        // Create a background context
        let context = ModelContext(modelContainer)
        context.autosaveEnabled = false

        // Perform the operation
        let result = try operation(context)

        // Save once at the end
        try context.save()

        return result
    }

    /// Batch inserts multiple records efficiently
    /// - Parameters:
    ///   - records: Array of records to insert
    ///   - batchSize: Number of records to insert per batch (default: 100)
    /// - Throws: SwiftData errors if insert fails
    func batchInsert<T>(_ records: [T], batchSize: Int = 100) async throws where T: PersistentModel {
        try await performBatchOperation { context in
            for (index, record) in records.enumerated() {
                context.insert(record)

                // Save periodically to avoid memory pressure
                if (index + 1) % batchSize == 0 {
                    try context.save()
                }
            }

            // Final save for remaining records
            try context.save()
        }
    }

    /// Batch deletes records matching a predicate
    /// - Parameters:
    ///   - predicate: The predicate to match records for deletion
    ///   - batchSize: Number of records to delete per batch (default: 100)
    /// - Throws: SwiftData errors if delete fails
    func batchDelete<T>(
        where predicate: Predicate<T>? = nil,
        batchSize: Int = 100
    ) async throws where T: PersistentModel {
        try await performBatchOperation { context in
            var descriptor = FetchDescriptor<T>()
            if let predicate = predicate {
                descriptor.predicate = predicate
            }

            let recordsToDelete = try context.fetch(descriptor)

            for (index, record) in recordsToDelete.enumerated() {
                context.delete(record)

                // Save periodically to avoid memory pressure
                if (index + 1) % batchSize == 0 {
                    try context.save()
                }
            }

            // Final save
            try context.save()
        }
    }
}
