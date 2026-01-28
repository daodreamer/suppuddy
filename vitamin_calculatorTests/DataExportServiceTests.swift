//
//  DataExportServiceTests.swift
//  vitamin_calculatorTests
//
//  Created for Sprint 6 - Task 3.2
//

import Foundation
import Testing
import SwiftData
@testable import vitamin_calculator

@Suite("DataExportService Tests - Sprint 6 Task 3.2")
struct DataExportServiceTests {

    @Suite("Data Collection Tests")
    struct DataCollectionTests {
        @Test("Service should collect all export data")
        @MainActor
        func testCollectExportData() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let userRepo = UserRepository(modelContext: context)
            let supplementRepo = SupplementRepository(modelContext: context)
            let intakeRepo = IntakeRecordRepository(modelContext: context)

            let service = DataExportService(
                userRepository: userRepo,
                supplementRepository: supplementRepo,
                intakeRepository: intakeRepo
            )

            // Create test data
            let user = UserProfile(name: "Test User", userType: .male)
            context.insert(user)

            let supplement = Supplement(
                name: "Test Supplement",
                brand: "Test Brand",
                servingSize: "1 tablet",
                servingsPerDay: 1,
                nutrients: [],
                isActive: true
            )
            context.insert(supplement)

            try context.save()

            // Act
            let exportData = try await service.collectExportData()

            // Assert
            #expect(exportData.userProfile != nil)
            #expect(exportData.userProfile?.name == "Test User")
            #expect(exportData.supplements.count == 1)
            #expect(exportData.supplements.first?.name == "Test Supplement")
            #expect(exportData.exportDate <= Date())
            #expect(exportData.appVersion.isEmpty == false)
        }

        @Test("Service should handle empty database")
        @MainActor
        func testCollectEmptyData() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let userRepo = UserRepository(modelContext: context)
            let supplementRepo = SupplementRepository(modelContext: context)
            let intakeRepo = IntakeRecordRepository(modelContext: context)

            let service = DataExportService(
                userRepository: userRepo,
                supplementRepository: supplementRepo,
                intakeRepository: intakeRepo
            )

            // Act
            let exportData = try await service.collectExportData()

            // Assert
            #expect(exportData.userProfile == nil)
            #expect(exportData.supplements.isEmpty)
            #expect(exportData.intakeRecords.isEmpty)
        }
    }

    @Suite("JSON Export Tests")
    struct JSONExportTests {
        @Test("Service should export data to JSON file")
        @MainActor
        func testExportToJSON() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let userRepo = UserRepository(modelContext: context)
            let supplementRepo = SupplementRepository(modelContext: context)
            let intakeRepo = IntakeRecordRepository(modelContext: context)

            let service = DataExportService(
                userRepository: userRepo,
                supplementRepository: supplementRepo,
                intakeRepository: intakeRepo
            )

            // Create test user
            let user = UserProfile(name: "JSON User", userType: .female)
            context.insert(user)
            try context.save()

            // Act
            let fileURL = try await service.exportToJSON()

            // Assert
            #expect(FileManager.default.fileExists(atPath: fileURL.path))
            #expect(fileURL.pathExtension == "json")

            // Verify JSON content
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode(ExportData.self, from: data)
            #expect(decoded.userProfile?.name == "JSON User")

            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }

        @Test("Exported JSON should be valid and parseable")
        @MainActor
        func testJSONValidity() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let service = DataExportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            // Act
            let fileURL = try await service.exportToJSON()
            let data = try Data(contentsOf: fileURL)

            // Assert - should be able to parse as JSON
            let _ = try JSONSerialization.jsonObject(with: data)

            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    @Suite("CSV Export Tests")
    struct CSVExportTests {
        @Test("Service should export supplements to CSV")
        @MainActor
        func testExportSupplementsToCSV() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let supplementRepo = SupplementRepository(modelContext: context)
            let service = DataExportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: supplementRepo,
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            // Create test supplement
            let supplement = Supplement(
                name: "CSV Test",
                brand: "Brand",
                servingSize: "1 tablet",
                servingsPerDay: 2,
                nutrients: [],
                isActive: true
            )
            context.insert(supplement)
            try context.save()

            // Act
            let fileURL = try await service.exportSupplementsToCSV()

            // Assert
            #expect(FileManager.default.fileExists(atPath: fileURL.path))
            #expect(fileURL.pathExtension == "csv")

            let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
            #expect(csvContent.contains("CSV Test"))
            #expect(csvContent.contains("Brand"))

            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }

        @Test("CSV should contain header row")
        @MainActor
        func testCSVHeader() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let service = DataExportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            // Act
            let fileURL = try await service.exportSupplementsToCSV()
            let csvContent = try String(contentsOf: fileURL, encoding: .utf8)

            // Assert
            let lines = csvContent.split(separator: "\n")
            #expect(lines.count > 0)
            #expect(lines.first?.contains("Name") == true)

            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }

        @Test("Service should export intake records to CSV")
        @MainActor
        func testExportIntakeRecordsToCSV() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let service = DataExportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            // Create test data
            let supplement = Supplement(
                name: "Record Test",
                brand: nil,
                servingSize: "1",
                servingsPerDay: 1,
                nutrients: [],
                isActive: true
            )
            context.insert(supplement)

            let record = IntakeRecord(
                supplement: supplement,
                supplementName: "Record Test",
                date: Date(),
                timeOfDay: .morning,
                servingsTaken: 1,
                nutrients: []
            )
            context.insert(record)
            try context.save()

            // Act
            let fromDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            let toDate = Date()
            let fileURL = try await service.exportIntakeRecordsToCSV(from: fromDate, to: toDate)

            // Assert
            #expect(FileManager.default.fileExists(atPath: fileURL.path))
            #expect(fileURL.pathExtension == "csv")

            let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
            #expect(csvContent.contains("Record Test"))

            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    @Suite("File Management Tests")
    struct FileManagementTests {
        @Test("Service should create files in documents directory")
        @MainActor
        func testFileLocation() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let service = DataExportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            // Act
            let fileURL = try await service.exportToJSON()

            // Assert
            let documentsPath = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first

            #expect(fileURL.path.contains(documentsPath?.path ?? ""))

            // Cleanup
            try? FileManager.default.removeItem(at: fileURL)
        }

        @Test("Exported files should have unique names")
        @MainActor
        func testUniqueFileNames() async throws {
            // Arrange
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: UserProfile.self, Supplement.self, IntakeRecord.self,
                configurations: config
            )
            let context = ModelContext(container)

            let service = DataExportService(
                userRepository: UserRepository(modelContext: context),
                supplementRepository: SupplementRepository(modelContext: context),
                intakeRepository: IntakeRecordRepository(modelContext: context)
            )

            // Act - export twice
            let file1 = try await service.exportToJSON()
            let file2 = try await service.exportToJSON()

            // Assert - files should have different names
            #expect(file1.lastPathComponent != file2.lastPathComponent)

            // Cleanup
            try? FileManager.default.removeItem(at: file1)
            try? FileManager.default.removeItem(at: file2)
        }
    }
}
