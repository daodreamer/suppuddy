//
//  DataExportService.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 3.2
//

import Foundation
import SwiftData

/// Service for exporting app data to various formats (JSON, CSV, PDF)
@MainActor
final class DataExportService {

    // MARK: - Properties

    private let userRepository: UserRepository
    private let supplementRepository: SupplementRepository
    private let intakeRepository: IntakeRecordRepository

    // MARK: - Initialization

    /// Creates a new data export service
    /// - Parameters:
    ///   - userRepository: Repository for user data
    ///   - supplementRepository: Repository for supplement data
    ///   - intakeRepository: Repository for intake records
    init(
        userRepository: UserRepository,
        supplementRepository: SupplementRepository,
        intakeRepository: IntakeRecordRepository
    ) {
        self.userRepository = userRepository
        self.supplementRepository = supplementRepository
        self.intakeRepository = intakeRepository
    }

    // MARK: - Public Methods

    /// Collects all exportable data from the app
    /// - Returns: An ExportData package containing all app data
    /// - Throws: Repository or encoding errors
    func collectExportData() async throws -> ExportData {
        // Get current user profile
        let userProfile = try await userRepository.getCurrentUser()
        let exportedProfile: ExportedUserProfile? = userProfile.map { profile in
            ExportedUserProfile(
                name: profile.name,
                userType: profile.userType.localizedDescription,
                specialNeeds: profile.specialNeeds?.rawValue
            )
        }

        // Get all supplements
        let supplements = try await supplementRepository.getAll()
        let exportedSupplements = supplements.map { supplement in
            ExportedSupplement(
                name: supplement.name,
                brand: supplement.brand,
                servingSize: supplement.servingSize,
                servingsPerDay: supplement.servingsPerDay,
                nutrients: supplement.nutrients.map { nutrient in
                    ExportedNutrient(
                        name: nutrient.type.localizedName,
                        amount: nutrient.amount,
                        unit: nutrient.type.unit
                    )
                },
                isActive: supplement.isActive
            )
        }

        // Get all intake records
        let intakeRecords = try await intakeRepository.getAll()
        let exportedRecords = intakeRecords.map { record in
            ExportedIntakeRecord(
                supplementName: record.supplementName,
                date: record.date,
                timeOfDay: record.timeOfDay.rawValue,
                servingsTaken: record.servingsTaken
            )
        }

        // Create export data package
        return ExportData(
            exportDate: Date(),
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            userProfile: exportedProfile,
            supplements: exportedSupplements,
            intakeRecords: exportedRecords,
            reminders: [] // TODO: Add reminders when implemented
        )
    }

    /// Exports all data to a JSON file
    /// - Returns: URL of the created JSON file
    /// - Throws: Export or file system errors
    func exportToJSON() async throws -> URL {
        let exportData = try await collectExportData()
        let jsonData = try exportData.toJSON()

        let fileURL = try createExportFileURL(filename: "VitaminCalculator_Export", extension: "json")
        try jsonData.write(to: fileURL)

        return fileURL
    }

    /// Exports supplements list to a CSV file
    /// - Returns: URL of the created CSV file
    /// - Throws: Export or file system errors
    func exportSupplementsToCSV() async throws -> URL {
        let exportData = try await collectExportData()
        let csvString = exportData.toCSV()

        let fileURL = try createExportFileURL(filename: "Supplements_Export", extension: "csv")
        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)

        return fileURL
    }

    /// Exports intake records within a date range to a CSV file
    /// - Parameters:
    ///   - from: Start date
    ///   - to: End date
    /// - Returns: URL of the created CSV file
    /// - Throws: Export or file system errors
    func exportIntakeRecordsToCSV(from: Date, to: Date) async throws -> URL {
        let records = try await intakeRepository.getByDateRange(from: from, to: to)

        var csv = "Supplement Name,Date,Time of Day,Servings Taken,Notes\n"

        for record in records {
            let dateFormatter = ISO8601DateFormatter()
            let dateString = dateFormatter.string(from: record.date)
            let notes = record.notes ?? ""

            csv += "\(escapeCSVField(record.supplementName)),\(dateString),\(record.timeOfDay.rawValue),\(record.servingsTaken),\(escapeCSVField(notes))\n"
        }

        let fileURL = try createExportFileURL(filename: "IntakeRecords_Export", extension: "csv")
        try csv.write(to: fileURL, atomically: true, encoding: .utf8)

        return fileURL
    }

    // MARK: - Private Helpers

    /// Creates a unique file URL in the documents directory
    /// - Parameters:
    ///   - filename: Base filename
    ///   - extension: File extension
    /// - Returns: URL for the file
    /// - Throws: File system errors
    private func createExportFileURL(filename: String, extension: String) throws -> URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())

        // Add a short UUID suffix to ensure uniqueness even for rapid consecutive exports
        let uuid = UUID().uuidString.prefix(8)

        let uniqueFilename = "\(filename)_\(timestamp)_\(uuid).\(`extension`)"
        return documentsPath.appendingPathComponent(uniqueFilename)
    }

    /// Escapes a CSV field by wrapping it in quotes if needed
    /// - Parameter field: The field to escape
    /// - Returns: Escaped field
    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }
}
