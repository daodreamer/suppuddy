import Foundation
import Observation
import SwiftData

/// ViewModel for the scan history view.
/// Manages loading, displaying, and managing scan history records.
@MainActor
@Observable
final class ScanHistoryViewModel {

    // MARK: - Properties

    /// List of scan history records
    var scanHistory: [ScanHistory] = []

    /// Whether data is currently being loaded
    var isLoading: Bool = false

    /// Error message to display
    var errorMessage: String?

    /// Currently selected history item
    var selectedHistory: ScanHistory?

    /// Product lookup service
    private let lookupService: any ProductLookupServiceProtocol

    // MARK: - Initialization

    /// Creates a new ScanHistoryViewModel
    /// - Parameter lookupService: Service for scan history operations
    init(lookupService: any ProductLookupServiceProtocol) {
        self.lookupService = lookupService
    }

    /// Convenience initializer with concrete type
    /// - Parameter lookupService: Product lookup service
    init(lookupService: ProductLookupService) {
        self.lookupService = lookupService
    }

    // MARK: - Load History

    /// Loads recent scan history
    func loadHistory() async {
        isLoading = true
        errorMessage = nil

        do {
            scanHistory = try await lookupService.getRecentScans()
        } catch {
            errorMessage = error.localizedDescription
            scanHistory = []
        }

        isLoading = false
    }

    // MARK: - Delete History

    /// Deletes a single history item
    /// - Parameter item: The history item to delete
    func deleteHistory(_ item: ScanHistory) async {
        errorMessage = nil

        do {
            // Delete from service
            try await lookupService.deleteHistory(item)

            // Reload to ensure consistency
            await loadHistory()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Clear All

    /// Clears all scan history
    func clearAllHistory() async {
        errorMessage = nil

        do {
            try await lookupService.clearHistory()
            scanHistory = []
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Selection

    /// Selects a history item
    /// - Parameter item: The history item to select
    func selectHistory(_ item: ScanHistory) {
        selectedHistory = item
    }

    /// Clears the current selection
    func clearSelection() {
        selectedHistory = nil
    }
}
