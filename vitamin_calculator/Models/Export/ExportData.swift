//
//  ExportData.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 1.2
//

import Foundation

// MARK: - ExportData

/// Main export data package containing all app data for backup/sharing
struct ExportData: Codable {
    /// Date when this export was created
    let exportDate: Date

    /// App version that created this export
    let appVersion: String

    /// User profile data (if any)
    let userProfile: ExportedUserProfile?

    /// List of all supplements
    let supplements: [ExportedSupplement]

    /// List of intake records
    let intakeRecords: [ExportedIntakeRecord]

    /// List of reminders
    let reminders: [ExportedReminder]

    // MARK: - Export Methods

    /// Converts the export data to JSON format
    /// - Returns: JSON data with pretty printing
    /// - Throws: Encoding errors
    func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }

    /// Converts supplements data to CSV format
    /// - Returns: CSV string with supplement data
    func toCSV() -> String {
        var csv = "Name,Brand,Serving Size,Servings Per Day,Nutrients,Active\n"

        for supplement in supplements {
            let brand = supplement.brand ?? ""
            let nutrients = supplement.nutrients.map { "\($0.name): \($0.amount)\($0.unit)" }.joined(separator: "; ")
            let active = supplement.isActive ? "Yes" : "No"

            // Escape commas and quotes in fields
            let escapedName = escapeCSVField(supplement.name)
            let escapedBrand = escapeCSVField(brand)
            let escapedServingSize = escapeCSVField(supplement.servingSize)
            let escapedNutrients = escapeCSVField(nutrients)

            csv += "\(escapedName),\(escapedBrand),\(escapedServingSize),\(supplement.servingsPerDay),\(escapedNutrients),\(active)\n"
        }

        return csv
    }

    // MARK: - Private Helpers

    /// Escapes a CSV field by wrapping it in quotes if it contains special characters
    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }
}

// MARK: - ExportedUserProfile

/// Simplified user profile for export
struct ExportedUserProfile: Codable {
    /// User's name
    let name: String

    /// User type as string (male, female, child)
    let userType: String

    /// Special needs as string (optional)
    let specialNeeds: String?
}

// MARK: - ExportedSupplement

/// Simplified supplement for export
struct ExportedSupplement: Codable {
    /// Supplement name
    let name: String

    /// Brand name (optional)
    let brand: String?

    /// Serving size description
    let servingSize: String

    /// Number of servings per day
    let servingsPerDay: Int

    /// List of nutrients in this supplement
    let nutrients: [ExportedNutrient]

    /// Whether this supplement is currently active
    let isActive: Bool
}

// MARK: - ExportedNutrient

/// Simplified nutrient for export
struct ExportedNutrient: Codable {
    /// Nutrient name
    let name: String

    /// Amount per serving
    let amount: Double

    /// Unit of measurement (mg, μg, etc.)
    let unit: String
}

// MARK: - ExportedIntakeRecord

/// Simplified intake record for export
struct ExportedIntakeRecord: Codable {
    /// Name of the supplement taken
    let supplementName: String

    /// Date and time when taken
    let date: Date

    /// Time of day category
    let timeOfDay: String

    /// Number of servings taken
    let servingsTaken: Int
}

// MARK: - ExportedReminder

/// Simplified reminder for export
struct ExportedReminder: Codable {
    /// Name of the supplement for this reminder
    let supplementName: String

    /// Time as string (HH:mm format)
    let time: String

    /// Repeat mode (Daily, Weekly, etc.)
    let repeatMode: String

    /// Whether this reminder is enabled
    let isEnabled: Bool
}
