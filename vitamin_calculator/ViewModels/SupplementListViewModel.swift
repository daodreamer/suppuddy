//
//  SupplementListViewModel.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import Foundation
import Observation
import SwiftData

/// ViewModel for managing the supplements list view.
/// Handles loading, searching, sorting, and managing supplements.
@MainActor
@Observable
final class SupplementListViewModel {

    // MARK: - Properties

    /// List of supplements to display
    var supplements: [Supplement] = []

    /// Whether data is currently being loaded
    var isLoading: Bool = false

    /// Error message to display to the user
    var errorMessage: String?

    /// Current search query
    var searchQuery: String = ""

    /// Current sort option
    var sortOption: SupplementSortOption = .name

    /// Whether to sort ascending
    var sortAscending: Bool = true

    /// Repository for data access
    let repository: SupplementRepository

    // MARK: - Initialization

    /// Creates a new SupplementListViewModel
    /// - Parameter repository: The repository for supplement data access
    init(repository: SupplementRepository) {
        self.repository = repository
    }

    // MARK: - Public Methods

    /// Loads all supplements from the repository
    func loadSupplements() async {
        isLoading = true
        errorMessage = nil

        do {
            supplements = try await repository.getAllSorted(by: sortOption, ascending: sortAscending)
        } catch {
            errorMessage = "Failed to load supplements: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Searches supplements by the current search query
    func search() async {
        isLoading = true
        errorMessage = nil

        do {
            if searchQuery.isEmpty {
                supplements = try await repository.getAllSorted(by: sortOption, ascending: sortAscending)
            } else {
                supplements = try await repository.search(query: searchQuery)
            }
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Deletes a supplement
    /// - Parameter supplement: The supplement to delete
    func delete(_ supplement: Supplement) async {
        do {
            try await repository.delete(supplement)
            supplements.removeAll { $0.persistentModelID == supplement.persistentModelID }
        } catch {
            errorMessage = "Failed to delete supplement: \(error.localizedDescription)"
        }
    }

    /// Toggles the active state of a supplement
    /// - Parameter supplement: The supplement to toggle
    func toggleActive(_ supplement: Supplement) async {
        supplement.isActive.toggle()
        do {
            try await repository.update(supplement)
        } catch {
            errorMessage = "Failed to update supplement: \(error.localizedDescription)"
            supplement.isActive.toggle() // Revert on failure
        }
    }

    // MARK: - Deinitialization

    // Sprint 7 Phase 1: Memory leak detection
    #if DEBUG
    deinit {
        print("✅ SupplementListViewModel deallocated")
    }
    #endif
}
