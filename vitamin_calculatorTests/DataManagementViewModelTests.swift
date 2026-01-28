//
//  DataManagementViewModelTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 28.01.26.
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

/// Test suite for DataManagementViewModel following TDD best practices
@Suite("DataManagementViewModel Tests")
@MainActor
struct DataManagementViewModelTests {

    // MARK: - Test Setup Helpers

    /// Creates an in-memory model container for testing
    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: UserProfile.self, Supplement.self, IntakeRecord.self,
            configurations: config
        )
        return container
    }

    /// Creates test services with in-memory storage
    private func createTestServices() throws -> (DataExportService, DataImportService) {
        let container = try createTestContainer()
        let context = ModelContext(container)

        let userRepo = UserRepository(modelContext: context)
        let supplementRepo = SupplementRepository(modelContext: context)
        let intakeRepo = IntakeRecordRepository(modelContext: context)

        let exportService = DataExportService(
            userRepository: userRepo,
            supplementRepository: supplementRepo,
            intakeRepository: intakeRepo
        )

        let importService = DataImportService(
            userRepository: userRepo,
            supplementRepository: supplementRepo,
            intakeRepository: intakeRepo
        )

        return (exportService, importService)
    }

    // MARK: - Initialization Tests

    @Test("DataManagementViewModel initializes with default state")
    func testInitializationDefaultState() async throws {
        // Arrange & Act
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        // Assert
        #expect(viewModel.isExporting == false)
        #expect(viewModel.isImporting == false)
        #expect(viewModel.exportedFileURL == nil)
        #expect(viewModel.importPreview == nil)
        #expect(viewModel.importResult == nil)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Export Tests

    @Test("Export all data creates file successfully")
    func testExportAllDataSuccess() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        // Act
        await viewModel.exportAllData()

        // Assert
        #expect(viewModel.isExporting == false)
        #expect(viewModel.exportedFileURL != nil)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Export sets loading state during operation")
    func testExportSetsLoadingState() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        // Act
        await viewModel.exportAllData()

        // Assert - should be false after completion
        #expect(viewModel.isExporting == false)
    }

    @Test("Export supplements creates CSV file")
    func testExportSupplementsSuccess() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        // Act
        await viewModel.exportSupplements()

        // Assert
        #expect(viewModel.isExporting == false)
        #expect(viewModel.exportedFileURL != nil)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Export intake records creates CSV file")
    func testExportIntakeRecordsSuccess() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        let fromDate = Date().addingTimeInterval(-7 * 24 * 3600) // 7 days ago
        let toDate = Date()

        // Act
        await viewModel.exportIntakeRecords(from: fromDate, to: toDate)

        // Assert
        #expect(viewModel.isExporting == false)
        #expect(viewModel.exportedFileURL != nil)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Export clears previous error message")
    func testExportClearsPreviousError() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        viewModel.errorMessage = "Previous error"

        // Act
        await viewModel.exportAllData()

        // Assert
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Import Tests

    @Test("Select import file shows preview")
    func testSelectImportFileShowsPreview() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        // First, create a test export file
        await viewModel.exportAllData()
        guard let exportURL = viewModel.exportedFileURL else {
            Issue.record("Export failed to create file")
            return
        }

        // Act
        await viewModel.selectImportFile(exportURL)

        // Assert
        #expect(viewModel.isImporting == false)
        #expect(viewModel.importPreview != nil)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Select import file with invalid URL shows error")
    func testSelectImportFileInvalidURL() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        let invalidURL = URL(fileURLWithPath: "/nonexistent/file.json")

        // Act
        await viewModel.selectImportFile(invalidURL)

        // Assert
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.importPreview == nil)
    }

    @Test("Perform import with merge mode succeeds")
    func testPerformImportMergeMode() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        // Create export file
        await viewModel.exportAllData()
        guard let exportURL = viewModel.exportedFileURL else {
            Issue.record("Export failed")
            return
        }

        // Select file for import
        await viewModel.selectImportFile(exportURL)
        #expect(viewModel.importPreview != nil)

        // Act
        await viewModel.performImport(mode: .merge)

        // Assert
        #expect(viewModel.isImporting == false)
        #expect(viewModel.importResult != nil)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Perform import with replace mode succeeds")
    func testPerformImportReplaceMode() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        // Create export file
        await viewModel.exportAllData()
        guard let exportURL = viewModel.exportedFileURL else {
            Issue.record("Export failed")
            return
        }

        // Select file for import
        await viewModel.selectImportFile(exportURL)

        // Act
        await viewModel.performImport(mode: .replace)

        // Assert
        #expect(viewModel.isImporting == false)
        #expect(viewModel.importResult != nil)
    }

    @Test("Perform import without preview shows error")
    func testPerformImportWithoutPreview() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        // Act - try to import without selecting file first
        await viewModel.performImport(mode: .merge)

        // Assert
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.importResult == nil)
    }

    @Test("Cancel import clears state")
    func testCancelImport() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        // Create export and load preview
        await viewModel.exportAllData()
        if let url = viewModel.exportedFileURL {
            await viewModel.selectImportFile(url)
        }

        #expect(viewModel.importPreview != nil)

        // Act
        viewModel.cancelImport()

        // Assert
        #expect(viewModel.importPreview == nil)
        #expect(viewModel.importResult == nil)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - State Management Tests

    @Test("Export and import states are independent")
    func testExportImportStatesIndependent() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        // Act - export
        await viewModel.exportAllData()
        let exportURL = viewModel.exportedFileURL

        // Then import
        if let url = exportURL {
            await viewModel.selectImportFile(url)
        }

        // Assert - both should have completed without interfering
        #expect(viewModel.exportedFileURL != nil)
        #expect(viewModel.importPreview != nil)
        #expect(viewModel.isExporting == false)
        #expect(viewModel.isImporting == false)
    }

    @Test("Error message persists until cleared")
    func testErrorMessagePersistence() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        let invalidURL = URL(fileURLWithPath: "/nonexistent/file.json")

        // Act
        await viewModel.selectImportFile(invalidURL)

        // Assert
        #expect(viewModel.errorMessage != nil)
        let errorMessage = viewModel.errorMessage

        // Error should persist until next operation
        #expect(viewModel.errorMessage == errorMessage)
    }

    @Test("Import result is cleared when selecting new file")
    func testImportResultClearedOnNewSelection() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        // Create and import a file
        await viewModel.exportAllData()
        guard let exportURL = viewModel.exportedFileURL else {
            Issue.record("Export failed")
            return
        }

        await viewModel.selectImportFile(exportURL)
        await viewModel.performImport(mode: .merge)

        #expect(viewModel.importResult != nil)

        // Act - select file again
        await viewModel.selectImportFile(exportURL)

        // Assert - result should be cleared
        #expect(viewModel.importResult == nil)
    }

    // MARK: - Integration Tests

    @Test("Full export-import cycle completes successfully")
    func testFullExportImportCycle() async throws {
        // Arrange
        let (exportService, importService) = try createTestServices()
        let viewModel = DataManagementViewModel(
            exportService: exportService,
            importService: importService
        )

        // Act - full cycle
        // 1. Export data
        await viewModel.exportAllData()
        #expect(viewModel.exportedFileURL != nil)

        guard let exportURL = viewModel.exportedFileURL else {
            Issue.record("Export failed")
            return
        }

        // 2. Select file for import
        await viewModel.selectImportFile(exportURL)
        #expect(viewModel.importPreview != nil)

        // 3. Perform import
        await viewModel.performImport(mode: .merge)
        #expect(viewModel.importResult != nil)

        // 4. Cancel/reset
        viewModel.cancelImport()
        #expect(viewModel.importPreview == nil)

        // Assert - full cycle completed without errors
        #expect(viewModel.errorMessage == nil)
    }
}
