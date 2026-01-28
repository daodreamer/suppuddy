//
//  DataManagementViewModel.swift
//  vitamin_calculator
//
//  Created by Claude Code on 28.01.26.
//

import Foundation
import Observation

/// ViewModel for managing data export and import operations.
///
/// Responsibilities:
/// - Export app data to JSON and CSV formats
/// - Import data from backup files
/// - Preview import data before performing import
/// - Handle merge and replace import modes
/// - Manage state for export and import operations
///
/// Usage:
/// ```swift
/// // Export
/// await viewModel.exportAllData()
/// if let url = viewModel.exportedFileURL {
///     // Share or save the file
/// }
///
/// // Import
/// await viewModel.selectImportFile(fileURL)
/// if viewModel.importPreview != nil {
///     await viewModel.performImport(mode: .merge)
/// }
/// ```
@MainActor
@Observable
final class DataManagementViewModel {

    // MARK: - Published Properties

    /// Indicates if an export operation is in progress.
    /// UI should show loading indicator when true.
    var isExporting: Bool = false

    /// Indicates if an import operation is in progress.
    /// UI should show loading indicator when true.
    var isImporting: Bool = false

    /// URL of the most recently exported file.
    /// Use this to share or display the file location.
    var exportedFileURL: URL?

    /// Preview of data to be imported.
    /// Shows counts and conflicts before performing import.
    var importPreview: ImportPreview?

    /// Result of the most recent import operation.
    /// Contains counts of imported items and any errors.
    var importResult: ImportResult?

    /// User-facing error message if operations fail.
    /// Automatically cleared on next operation.
    var errorMessage: String?

    // MARK: - Private Properties

    private let exportService: DataExportService
    private let importService: DataImportService
    private var pendingExportData: ExportData?

    // MARK: - Initialization

    /// Creates a new data management view model
    /// - Parameters:
    ///   - exportService: Service for exporting data
    ///   - importService: Service for importing data
    init(exportService: DataExportService, importService: DataImportService) {
        self.exportService = exportService
        self.importService = importService
    }

    // MARK: - Export Methods

    /// Exports all app data to JSON format.
    /// Creates a JSON file in the documents directory and sets exportedFileURL.
    func exportAllData() async {
        isExporting = true
        errorMessage = nil
        exportedFileURL = nil

        do {
            let fileURL = try await exportService.exportToJSON()
            exportedFileURL = fileURL
        } catch {
            errorMessage = error.localizedDescription
        }

        isExporting = false
    }

    /// Exports supplement list to CSV format.
    /// Creates a CSV file with all supplements.
    func exportSupplements() async {
        isExporting = true
        errorMessage = nil
        exportedFileURL = nil

        do {
            let fileURL = try await exportService.exportSupplementsToCSV()
            exportedFileURL = fileURL
        } catch {
            errorMessage = error.localizedDescription
        }

        isExporting = false
    }

    /// Exports intake records to CSV format for a date range.
    /// - Parameters:
    ///   - from: Start date for records
    ///   - to: End date for records
    func exportIntakeRecords(from: Date, to: Date) async {
        isExporting = true
        errorMessage = nil
        exportedFileURL = nil

        do {
            let fileURL = try await exportService.exportIntakeRecordsToCSV(from: from, to: to)
            exportedFileURL = fileURL
        } catch {
            errorMessage = error.localizedDescription
        }

        isExporting = false
    }

    /// Generates a nutrition report PDF (optional feature).
    /// - Parameters:
    ///   - from: Start date for report
    ///   - to: End date for report
    func generateReport(from: Date, to: Date) async {
        // TODO: Implement PDF generation in future sprint
        errorMessage = "PDF generation not yet implemented"
    }

    // MARK: - Import Methods

    /// Selects a file for import and shows preview of the data.
    /// Clears previous import result and loads preview.
    /// - Parameter url: URL of the file to import
    func selectImportFile(_ url: URL) async {
        isImporting = true
        errorMessage = nil
        importResult = nil

        do {
            // Parse the file and get preview
            let preview = try await importService.parseImportFile(url)
            importPreview = preview

            // Store the export data for later import
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            pendingExportData = try decoder.decode(ExportData.self, from: data)
        } catch let error as ImportError {
            errorMessage = error.description
            importPreview = nil
        } catch {
            errorMessage = error.localizedDescription
            importPreview = nil
        }

        isImporting = false
    }

    /// Performs the import operation with the selected mode.
    /// Requires that selectImportFile was called first.
    /// - Parameter mode: Import mode (merge or replace)
    func performImport(mode: ImportMode) async {
        guard let exportData = pendingExportData else {
            errorMessage = "请先选择要导入的文件"
            return
        }

        isImporting = true
        errorMessage = nil

        do {
            let result = try await importService.performImport(exportData, mode: mode)
            importResult = result

            // Set error message if there were errors during import
            if !result.errors.isEmpty {
                let errorMessages = result.errors.map { $0.description }.joined(separator: "\n")
                errorMessage = "导入时出现错误:\n\(errorMessages)"
            }
        } catch let error as ImportError {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }

        isImporting = false
    }

    /// Cancels the import and clears all import-related state.
    func cancelImport() {
        importPreview = nil
        importResult = nil
        errorMessage = nil
        pendingExportData = nil
    }
}
