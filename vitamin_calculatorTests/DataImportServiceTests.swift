//
//  DataImportServiceTests.swift
//  vitamin_calculatorTests
//
//  Created for Sprint 6 - Task 3.3
//  Following TDD Best Practices
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("DataImportService Tests - Sprint 6 Task 3.3")
struct DataImportServiceTests {

    // MARK: - Test Helpers

    /// Creates a test ExportData package for import testing
    private func createTestExportData() -> ExportData {
        return ExportData(
            exportDate: Date(),
            appVersion: "1.0",
            userProfile: ExportedUserProfile(
                name: "Test User",
                userType: "male",
                specialNeeds: nil
            ),
            supplements: [
                ExportedSupplement(
                    name: "Test Supplement",
                    brand: "Test Brand",
                    servingSize: "1 tablet",
                    servingsPerDay: 1,
                    nutrients: [
                        ExportedNutrient(name: "Vitamin C", amount: 100.0, unit: "mg")
                    ],
                    isActive: true
                )
            ],
            intakeRecords: [
                ExportedIntakeRecord(
                    supplementName: "Test Supplement",
                    date: Date(),
                    timeOfDay: "morning",
                    servingsTaken: 1
                )
            ],
            reminders: []
        )
    }

    /// Creates a test JSON file for import testing
    private func createTestJSONFile() throws -> URL {
        let exportData = createTestExportData()
        let jsonData = try exportData.toJSON()

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("test_import_\(UUID().uuidString).json")
        try jsonData.write(to: fileURL)

        return fileURL
    }

    // MARK: - JSON Parsing Tests

    @Suite("JSON Parsing Tests")
    struct JSONParsingTests {

        @Test("Service should parse valid JSON import file")
        @MainActor
        func testParseValidJSON() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let service = DataImportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            // Create test file
            let exportData = ExportData(
                exportDate: Date(),
                appVersion: "1.0",
                userProfile: ExportedUserProfile(name: "Test", userType: "male", specialNeeds: nil),
                supplements: [],
                intakeRecords: [],
                reminders: []
            )
            let jsonData = try exportData.toJSON()
            let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("test.json")
            try jsonData.write(to: tempFile)

            // Act
            let preview = try await service.parseImportFile(tempFile)

            // Assert
            #expect(preview.hasUserProfile == true)
            #expect(preview.supplementCount == 0)

            // Cleanup
            try? FileManager.default.removeItem(at: tempFile)
        }

        @Test("Service should handle invalid JSON file")
        @MainActor
        func testParseInvalidJSON() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let service = DataImportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            // Create invalid JSON file
            let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("invalid.json")
            try "{ invalid json }".write(to: tempFile, atomically: true, encoding: .utf8)

            // Act & Assert
            await #expect(throws: Error.self) {
                try await service.parseImportFile(tempFile)
            }

            // Cleanup
            try? FileManager.default.removeItem(at: tempFile)
        }

        @Test("Service should handle missing file")
        @MainActor
        func testParseMissingFile() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let service = DataImportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            let missingFile = FileManager.default.temporaryDirectory.appendingPathComponent("missing.json")

            // Act & Assert
            await #expect(throws: Error.self) {
                try await service.parseImportFile(missingFile)
            }
        }
    }

    // MARK: - Data Validation Tests

    @Suite("Data Validation Tests")
    struct DataValidationTests {

        @Test("Service should validate correct import data")
        @MainActor
        func testValidateCorrectData() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let service = DataImportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            let exportData = ExportData(
                exportDate: Date(),
                appVersion: "1.0",
                userProfile: ExportedUserProfile(name: "Test", userType: "male", specialNeeds: nil),
                supplements: [
                    ExportedSupplement(
                        name: "Valid Supplement",
                        brand: "Brand",
                        servingSize: "1 tablet",
                        servingsPerDay: 1,
                        nutrients: [],
                        isActive: true
                    )
                ],
                intakeRecords: [],
                reminders: []
            )

            // Act
            let errors = await service.validateImportData(exportData)

            // Assert
            #expect(errors.isEmpty)
        }

        @Test("Service should detect invalid supplement data")
        @MainActor
        func testValidateInvalidSupplementData() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let service = DataImportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            let exportData = ExportData(
                exportDate: Date(),
                appVersion: "1.0",
                userProfile: nil,
                supplements: [
                    ExportedSupplement(
                        name: "",  // Empty name - invalid
                        brand: nil,
                        servingSize: "1",
                        servingsPerDay: 0,  // Zero servings - invalid
                        nutrients: [],
                        isActive: true
                    )
                ],
                intakeRecords: [],
                reminders: []
            )

            // Act
            let errors = await service.validateImportData(exportData)

            // Assert
            #expect(errors.isEmpty == false)
        }
    }

    // MARK: - Conflict Detection Tests

    @Suite("Conflict Detection Tests")
    struct ConflictDetectionTests {

        @Test("Service should detect supplement name conflicts")
        @MainActor
        func testDetectSupplementConflicts() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            // Create existing supplement
            let existing = Supplement(
                name: "Existing Supplement",
                brand: "Brand A",
                servingSize: "1",
                servingsPerDay: 1,
                nutrients: [],
                isActive: true
            )
            context.insert(existing)
            try context.save()

            let service = DataImportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            // Import data with same name
            let importData = ExportData(
                exportDate: Date(),
                appVersion: "1.0",
                userProfile: nil,
                supplements: [
                    ExportedSupplement(
                        name: "Existing Supplement",
                        brand: "Brand B",
                        servingSize: "2",
                        servingsPerDay: 2,
                        nutrients: [],
                        isActive: true
                    )
                ],
                intakeRecords: [],
                reminders: []
            )

            // Act
            let preview = try await service.parseImportPreview(importData)

            // Assert
            #expect(preview.conflicts.isEmpty == false)
            #expect(preview.conflicts.first?.existingName == "Existing Supplement")
        }

        @Test("Service should not detect conflicts for new supplements")
        @MainActor
        func testNoConflictsForNewSupplements() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let service = DataImportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            let importData = ExportData(
                exportDate: Date(),
                appVersion: "1.0",
                userProfile: nil,
                supplements: [
                    ExportedSupplement(
                        name: "New Supplement",
                        brand: "Brand",
                        servingSize: "1",
                        servingsPerDay: 1,
                        nutrients: [],
                        isActive: true
                    )
                ],
                intakeRecords: [],
                reminders: []
            )

            // Act
            let preview = try await service.parseImportPreview(importData)

            // Assert
            #expect(preview.conflicts.isEmpty)
        }
    }

    // MARK: - Import Mode Tests

    @Suite("Import Mode Tests")
    struct ImportModeTests {

        @Test("Service should perform merge import")
        @MainActor
        func testMergeImport() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            // Create existing supplement
            let existing = Supplement(
                name: "Existing",
                brand: nil,
                servingSize: "1",
                servingsPerDay: 1,
                nutrients: [],
                isActive: true
            )
            context.insert(existing)
            try context.save()

            let service = DataImportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            let importData = ExportData(
                exportDate: Date(),
                appVersion: "1.0",
                userProfile: nil,
                supplements: [
                    ExportedSupplement(
                        name: "New Supplement",
                        brand: "Brand",
                        servingSize: "1",
                        servingsPerDay: 1,
                        nutrients: [],
                        isActive: true
                    )
                ],
                intakeRecords: [],
                reminders: []
            )

            // Act
            let result = try await service.performImport(importData, mode: .merge)

            // Assert
            #expect(result.supplementsImported == 1)

            // Verify existing supplement is still there
            let allSupplements = try await SupplementRepository(modelContext: context).getAll()
            #expect(allSupplements.count == 2)
        }

        @Test("Service should perform replace import")
        @MainActor
        func testReplaceImport() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            // Create existing supplement
            let existing = Supplement(
                name: "Existing",
                brand: nil,
                servingSize: "1",
                servingsPerDay: 1,
                nutrients: [],
                isActive: true
            )
            context.insert(existing)
            try context.save()

            let service = DataImportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            let importData = ExportData(
                exportDate: Date(),
                appVersion: "1.0",
                userProfile: nil,
                supplements: [
                    ExportedSupplement(
                        name: "New Supplement",
                        brand: "Brand",
                        servingSize: "1",
                        servingsPerDay: 1,
                        nutrients: [],
                        isActive: true
                    )
                ],
                intakeRecords: [],
                reminders: []
            )

            // Act
            let result = try await service.performImport(importData, mode: .replace)

            // Assert
            #expect(result.supplementsImported == 1)

            // Verify old supplement is removed
            let allSupplements = try await SupplementRepository(modelContext: context).getAll()
            #expect(allSupplements.count == 1)
            #expect(allSupplements.first?.name == "New Supplement")
        }
    }

    // MARK: - Integration Tests

    @Suite("Integration Tests")
    struct IntegrationTests {

        @Test("Service should import complete data package")
        @MainActor
        func testImportCompletePackage() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let service = DataImportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            let importData = ExportData(
                exportDate: Date(),
                appVersion: "1.0",
                userProfile: ExportedUserProfile(name: "Test User", userType: "female", specialNeeds: nil),
                supplements: [
                    ExportedSupplement(
                        name: "Supplement A",
                        brand: "Brand A",
                        servingSize: "1 tablet",
                        servingsPerDay: 2,
                        nutrients: [
                            ExportedNutrient(name: "Vitamin C", amount: 100.0, unit: "mg")
                        ],
                        isActive: true
                    ),
                    ExportedSupplement(
                        name: "Supplement B",
                        brand: "Brand B",
                        servingSize: "1 capsule",
                        servingsPerDay: 1,
                        nutrients: [],
                        isActive: false
                    )
                ],
                intakeRecords: [
                    ExportedIntakeRecord(
                        supplementName: "Supplement A",
                        date: Date(),
                        timeOfDay: "morning",
                        servingsTaken: 2
                    )
                ],
                reminders: []
            )

            // Act
            let result = try await service.performImport(importData, mode: .replace)

            // Assert
            #expect(result.supplementsImported == 2)
            #expect(result.intakeRecordsImported == 1)
            #expect(result.errors.isEmpty)

            // Verify data
            let userProfile = try await UserRepository(modelContext: context).getCurrentUser()
            #expect(userProfile?.name == "Test User")

            let supplements = try await SupplementRepository(modelContext: context).getAll()
            #expect(supplements.count == 2)
        }
    }
}
