//
//  SupplementRepository.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import SwiftData

/// Sort options for supplement queries
enum SupplementSortOption {
    case name
    case createdAt
    case updatedAt
}

/// Repository for managing Supplement data persistence using SwiftData.
/// Provides CRUD operations for supplements with search and sort capabilities.
@MainActor
final class SupplementRepository {

    // MARK: - Properties

    private let modelContext: ModelContext

    // MARK: - Initialization

    /// Creates a new supplement repository with the specified model context
    /// - Parameter modelContext: The SwiftData model context to use for persistence
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Create

    /// Saves a supplement to the database
    /// - Parameter supplement: The supplement to save
    /// - Throws: SwiftData errors if save fails
    func save(_ supplement: Supplement) async throws {
        // Ensure nutrients are properly encoded before insertion
        // This triggers the setter which encodes the nutrients data
        let nutrients = supplement.nutrients
        supplement.nutrients = nutrients

        modelContext.insert(supplement)

        // Force save the context to persist the changes
        do {
            try modelContext.save()
        } catch {
            // If save fails, remove the supplement from context
            modelContext.delete(supplement)
            throw error
        }
    }

    // MARK: - Read

    /// Retrieves all supplements from the database
    /// - Returns: Array of all supplements
    /// - Throws: SwiftData errors if fetch fails
    func getAll() async throws -> [Supplement] {
        let descriptor = FetchDescriptor<Supplement>()
        return try modelContext.fetch(descriptor)
    }

    /// Retrieves all active supplements from the database
    /// - Returns: Array of active supplements
    /// - Throws: SwiftData errors if fetch fails
    func getActive() async throws -> [Supplement] {
        let descriptor = FetchDescriptor<Supplement>(
            predicate: #Predicate { $0.isActive == true }
        )
        return try modelContext.fetch(descriptor)
    }

    /// Retrieves a supplement by its persistent identifier
    /// - Parameter id: The persistent model ID
    /// - Returns: The supplement if found, nil otherwise
    /// - Throws: SwiftData errors if fetch fails
    func getById(_ id: PersistentIdentifier) async throws -> Supplement? {
        let descriptor = FetchDescriptor<Supplement>()
        let supplements = try modelContext.fetch(descriptor)
        return supplements.first { $0.persistentModelID == id }
    }

    /// Retrieves all supplements sorted by the specified field
    /// - Parameters:
    ///   - sortOption: The field to sort by
    ///   - ascending: Sort order (true for ascending, false for descending)
    /// - Returns: Sorted array of supplements
    /// - Throws: SwiftData errors if fetch fails
    func getAllSorted(by sortOption: SupplementSortOption, ascending: Bool) async throws -> [Supplement] {
        var descriptor = FetchDescriptor<Supplement>()

        switch sortOption {
        case .name:
            descriptor.sortBy = [SortDescriptor(\.name, order: ascending ? .forward : .reverse)]
        case .createdAt:
            descriptor.sortBy = [SortDescriptor(\.createdAt, order: ascending ? .forward : .reverse)]
        case .updatedAt:
            descriptor.sortBy = [SortDescriptor(\.updatedAt, order: ascending ? .forward : .reverse)]
        }

        return try modelContext.fetch(descriptor)
    }

    // MARK: - Update

    /// Updates an existing supplement
    /// - Parameter supplement: The supplement to update
    /// - Throws: SwiftData errors if update fails
    func update(_ supplement: Supplement) async throws {
        supplement.updatedAt = Date()

        // Ensure nutrients are properly re-encoded after update
        let nutrients = supplement.nutrients
        supplement.nutrients = nutrients

        try modelContext.save()
    }

    // MARK: - Delete

    /// Deletes a supplement from the database
    /// - Parameter supplement: The supplement to delete
    /// - Throws: SwiftData errors if delete fails
    func delete(_ supplement: Supplement) async throws {
        modelContext.delete(supplement)
        try modelContext.save()
    }

    /// Deletes all supplements from the database
    /// - Throws: SwiftData errors if delete fails
    func deleteAll() async throws {
        let descriptor = FetchDescriptor<Supplement>()
        let supplements = try modelContext.fetch(descriptor)

        for supplement in supplements {
            modelContext.delete(supplement)
        }

        try modelContext.save()
    }

    // MARK: - Search

    /// Searches supplements by name or brand
    /// - Parameter query: The search query string
    /// - Returns: Array of matching supplements
    /// - Throws: SwiftData errors if fetch fails
    func search(query: String) async throws -> [Supplement] {
        // If query is empty, return all
        guard !query.isEmpty else {
            return try await getAll()
        }

        let lowercasedQuery = query.lowercased()

        // Fetch all and filter in memory since SwiftData predicates
        // have limited support for case-insensitive contains
        let descriptor = FetchDescriptor<Supplement>()
        let allSupplements = try modelContext.fetch(descriptor)

        return allSupplements.filter { supplement in
            supplement.name.lowercased().contains(lowercasedQuery) ||
            (supplement.brand?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }
}
