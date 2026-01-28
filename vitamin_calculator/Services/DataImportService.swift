//
//  DataImportService.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 3.3
//  Following TDD Best Practices
//

import Foundation
import SwiftData

// MARK: - Import Preview

/// Preview of data to be imported, showing counts and potential conflicts
struct ImportPreview {
    /// Number of supplements to be imported
    let supplementCount: Int

    /// Number of intake records to be imported
    let intakeRecordCount: Int

    /// Number of reminders to be imported
    let reminderCount: Int

    /// Whether the import includes a user profile
    let hasUserProfile: Bool

    /// List of conflicts with existing data
    let conflicts: [ImportConflict]
}

// MARK: - Import Mode

/// Mode for handling conflicts during import
enum ImportMode {
    /// Merge: Keep existing data and add new items (skip conflicts)
    case merge

    /// Replace: Delete existing data and import all new data
    case replace
}

// MARK: - Import Conflict

/// Represents a conflict between imported data and existing data
struct ImportConflict {
    /// Type of conflict
    let type: ConflictType

    /// Name of existing item
    let existingName: String

    /// Name of importing item
    let importingName: String

    /// Additional details about the conflict
    let details: String?

    enum ConflictType {
        case supplement
        case reminder
    }
}

// MARK: - Import Result

/// Result of an import operation
struct ImportResult {
    /// Number of supplements successfully imported
    let supplementsImported: Int

    /// Number of intake records successfully imported
    let intakeRecordsImported: Int

    /// Number of reminders successfully imported
    let remindersImported: Int

    /// List of errors encountered during import
    let errors: [ImportError]

    /// Whether the import was partially successful
    var isPartialSuccess: Bool {
        (supplementsImported > 0 || intakeRecordsImported > 0 || remindersImported > 0) && !errors.isEmpty
    }

    /// Whether the import was completely successful
    var isSuccess: Bool {
        errors.isEmpty
    }
}

// MARK: - Import Error

/// Errors that can occur during import
enum ImportError: Error, CustomStringConvertible {
    case fileNotFound
    case invalidFormat
    case corruptedData
    case validationFailed(String)
    case importFailed(String)

    var description: String {
        switch self {
        case .fileNotFound:
            return "Import file not found"
        case .invalidFormat:
            return "Invalid file format"
        case .corruptedData:
            return "File data is corrupted"
        case .validationFailed(let message):
            return "Validation failed: \(message)"
        case .importFailed(let message):
            return "Import failed: \(message)"
        }
    }
}

// MARK: - Validation Error

/// Validation errors for import data
struct ImportValidationError {
    let field: String
    let message: String
}

// MARK: - Data Import Service

/// Service for importing app data from various formats (JSON, CSV)
@MainActor
final class DataImportService {

    // MARK: - Properties

    private let userRepository: UserRepository
    private let supplementRepository: SupplementRepository
    private let intakeRepository: IntakeRecordRepository

    // MARK: - Initialization

    /// Creates a new data import service
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

    /// Parses an import file and returns a preview of the data
    /// - Parameter url: URL of the import file
    /// - Returns: Preview of import data
    /// - Throws: ImportError if parsing fails
    func parseImportFile(_ url: URL) async throws -> ImportPreview {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ImportError.fileNotFound
        }

        // Read file data
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ImportError.fileNotFound
        }

        // Decode JSON
        let exportData: ExportData
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            exportData = try decoder.decode(ExportData.self, from: data)
        } catch {
            throw ImportError.invalidFormat
        }

        // Create preview
        return try await parseImportPreview(exportData)
    }

    /// Creates an import preview from export data
    /// - Parameter data: Export data to preview
    /// - Returns: Import preview
    func parseImportPreview(_ data: ExportData) async throws -> ImportPreview {
        // Detect conflicts
        let conflicts = await detectConflicts(in: data)

        return ImportPreview(
            supplementCount: data.supplements.count,
            intakeRecordCount: data.intakeRecords.count,
            reminderCount: data.reminders.count,
            hasUserProfile: data.userProfile != nil,
            conflicts: conflicts
        )
    }

    /// Validates import data for correctness
    /// - Parameter data: Export data to validate
    /// - Returns: List of validation errors (empty if valid)
    func validateImportData(_ data: ExportData) async -> [ImportValidationError] {
        var errors: [ImportValidationError] = []

        // Validate supplements
        for (index, supplement) in data.supplements.enumerated() {
            if supplement.name.trimmingCharacters(in: .whitespaces).isEmpty {
                errors.append(ImportValidationError(
                    field: "supplements[\(index)].name",
                    message: "Supplement name cannot be empty"
                ))
            }

            if supplement.servingsPerDay <= 0 {
                errors.append(ImportValidationError(
                    field: "supplements[\(index)].servingsPerDay",
                    message: "Servings per day must be greater than 0"
                ))
            }

            if supplement.servingSize.trimmingCharacters(in: .whitespaces).isEmpty {
                errors.append(ImportValidationError(
                    field: "supplements[\(index)].servingSize",
                    message: "Serving size cannot be empty"
                ))
            }
        }

        // Validate intake records
        for (index, record) in data.intakeRecords.enumerated() {
            if record.supplementName.trimmingCharacters(in: .whitespaces).isEmpty {
                errors.append(ImportValidationError(
                    field: "intakeRecords[\(index)].supplementName",
                    message: "Supplement name cannot be empty"
                ))
            }

            if record.servingsTaken <= 0 {
                errors.append(ImportValidationError(
                    field: "intakeRecords[\(index)].servingsTaken",
                    message: "Servings taken must be greater than 0"
                ))
            }
        }

        return errors
    }

    /// Performs the import operation
    /// - Parameters:
    ///   - data: Export data to import
    ///   - mode: Import mode (merge or replace)
    /// - Returns: Import result with counts and errors
    /// - Throws: ImportError if import fails completely
    func performImport(_ data: ExportData, mode: ImportMode) async throws -> ImportResult {
        var importedSupplements = 0
        var importedRecords = 0
        var importedReminders = 0
        var errors: [ImportError] = []

        // Validate data first
        let validationErrors = await validateImportData(data)
        if !validationErrors.isEmpty {
            let errorMessages = validationErrors.map { "\($0.field): \($0.message)" }.joined(separator: ", ")
            throw ImportError.validationFailed(errorMessages)
        }

        // Handle replace mode: delete existing data
        if mode == .replace {
            do {
                try await deleteAllExistingData()
            } catch {
                throw ImportError.importFailed("Failed to clear existing data: \(error.localizedDescription)")
            }
        }

        // Import user profile
        if let userProfile = data.userProfile {
            do {
                try await importUserProfile(userProfile)
            } catch {
                errors.append(.importFailed("Failed to import user profile: \(error.localizedDescription)"))
            }
        }

        // Import supplements
        for supplement in data.supplements {
            do {
                try await importSupplement(supplement, mode: mode)
                importedSupplements += 1
            } catch {
                errors.append(.importFailed("Failed to import supplement '\(supplement.name)': \(error.localizedDescription)"))
            }
        }

        // Import intake records
        for record in data.intakeRecords {
            do {
                try await importIntakeRecord(record)
                importedRecords += 1
            } catch {
                errors.append(.importFailed("Failed to import intake record: \(error.localizedDescription)"))
            }
        }

        // Import reminders (TODO: when reminder feature is implemented)
        importedReminders = 0

        return ImportResult(
            supplementsImported: importedSupplements,
            intakeRecordsImported: importedRecords,
            remindersImported: importedReminders,
            errors: errors
        )
    }

    // MARK: - Private Helper Methods

    /// Detects conflicts between import data and existing data
    private func detectConflicts(in data: ExportData) async -> [ImportConflict] {
        var conflicts: [ImportConflict] = []

        // Get existing supplements
        let existingSupplements = (try? await supplementRepository.getAll()) ?? []
        let existingNames = Set(existingSupplements.map { $0.name })

        // Check for supplement name conflicts
        for supplement in data.supplements {
            if existingNames.contains(supplement.name) {
                conflicts.append(ImportConflict(
                    type: .supplement,
                    existingName: supplement.name,
                    importingName: supplement.name,
                    details: "A supplement with this name already exists"
                ))
            }
        }

        return conflicts
    }

    /// Deletes all existing data (for replace mode)
    private func deleteAllExistingData() async throws {
        // Delete all supplements
        let supplements = try await supplementRepository.getAll()
        for supplement in supplements {
            try await supplementRepository.delete(supplement)
        }

        // Delete all intake records
        let records = try await intakeRepository.getAll()
        for record in records {
            try await intakeRepository.delete(record)
        }

        // Delete user profile if exists
        if let user = try await userRepository.getCurrentUser() {
            try await userRepository.delete(user)
        }
    }

    /// Imports a user profile
    private func importUserProfile(_ profile: ExportedUserProfile) async throws {
        // Parse user type
        let userType: UserType
        switch profile.userType.lowercased() {
        case "male":
            userType = .male
        case "female":
            userType = .female
        case let childType where childType.starts(with: "child"):
            // Extract age if available, default to age 10
            userType = .child(age: 10)
        default:
            userType = .male // Default fallback
        }

        // Parse special needs
        let specialNeeds: SpecialNeeds?
        if let needsString = profile.specialNeeds {
            specialNeeds = SpecialNeeds(rawValue: needsString)
        } else {
            specialNeeds = nil
        }

        // Create user profile
        let newProfile = UserProfile(
            name: profile.name,
            userType: userType
        )

        // Set special needs if available
        if let needs = specialNeeds {
            newProfile.specialNeeds = needs
        }

        try await userRepository.save(newProfile)
    }

    /// Imports a supplement
    private func importSupplement(_ supplement: ExportedSupplement, mode: ImportMode) async throws {
        // In merge mode, check if supplement already exists
        if mode == .merge {
            let existing = try await supplementRepository.getAll()
            if existing.contains(where: { $0.name == supplement.name }) {
                // Skip this supplement in merge mode
                return
            }
        }

        // Convert nutrients
        var nutrients: [Nutrient] = []
        for exportedNutrient in supplement.nutrients {
            // Find matching nutrient type
            if let nutrientType = NutrientType.allCases.first(where: { $0.localizedName == exportedNutrient.name }) {
                let nutrient = Nutrient(
                    type: nutrientType,
                    amount: exportedNutrient.amount
                )
                nutrients.append(nutrient)
            }
        }

        // Create supplement
        let newSupplement = Supplement(
            name: supplement.name,
            brand: supplement.brand,
            servingSize: supplement.servingSize,
            servingsPerDay: supplement.servingsPerDay,
            nutrients: nutrients,
            isActive: supplement.isActive
        )

        try await supplementRepository.save(newSupplement)
    }

    /// Imports an intake record
    private func importIntakeRecord(_ record: ExportedIntakeRecord) async throws {
        // Find the supplement by name
        let supplements = try await supplementRepository.getAll()
        guard let supplement = supplements.first(where: { $0.name == record.supplementName }) else {
            throw ImportError.importFailed("Supplement '\(record.supplementName)' not found")
        }

        // Parse time of day
        let timeOfDay = TimeOfDay(rawValue: record.timeOfDay) ?? .morning

        // Calculate nutrients from supplement (keep as snapshot with original amounts)
        let nutrients = supplement.nutrients

        // Create intake record
        let newRecord = IntakeRecord(
            supplement: supplement,
            supplementName: record.supplementName,
            date: record.date,
            timeOfDay: timeOfDay,
            servingsTaken: record.servingsTaken,
            nutrients: nutrients
        )

        try await intakeRepository.save(newRecord)
    }
}
