//
//  ExportDataTests.swift
//  vitamin_calculatorTests
//
//  Created for Sprint 6 - Task 1.2
//  TDD: Red phase - writing tests first
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("ExportData Model Tests")
struct ExportDataTests {

    @Suite("ExportedUserProfile Tests")
    struct ExportedUserProfileTests {
        @Test("ExportedUserProfile should initialize with all fields")
        func testInitialization() {
            // Arrange & Act
            let profile = ExportedUserProfile(
                name: "Test User",
                userType: "male",
                specialNeeds: "孕期"
            )

            // Assert
            #expect(profile.name == "Test User")
            #expect(profile.userType == "male")
            #expect(profile.specialNeeds == "孕期")
        }

        @Test("ExportedUserProfile should encode to JSON")
        func testEncoding() throws {
            // Arrange
            let profile = ExportedUserProfile(
                name: "Test",
                userType: "female",
                specialNeeds: nil
            )

            // Act
            let encoder = JSONEncoder()
            let data = try encoder.encode(profile)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            // Assert
            #expect(json?["name"] as? String == "Test")
            #expect(json?["userType"] as? String == "female")
        }

        @Test("ExportedUserProfile should decode from JSON")
        func testDecoding() throws {
            // Arrange
            let jsonString = """
            {
                "name": "Jane",
                "userType": "female",
                "specialNeeds": "哺乳期"
            }
            """
            let data = jsonString.data(using: .utf8)!

            // Act
            let decoder = JSONDecoder()
            let profile = try decoder.decode(ExportedUserProfile.self, from: data)

            // Assert
            #expect(profile.name == "Jane")
            #expect(profile.userType == "female")
            #expect(profile.specialNeeds == "哺乳期")
        }
    }

    @Suite("ExportedNutrient Tests")
    struct ExportedNutrientTests {
        @Test("ExportedNutrient should initialize correctly")
        func testInitialization() {
            // Arrange & Act
            let nutrient = ExportedNutrient(
                name: "Vitamin C",
                amount: 100.0,
                unit: "mg"
            )

            // Assert
            #expect(nutrient.name == "Vitamin C")
            #expect(nutrient.amount == 100.0)
            #expect(nutrient.unit == "mg")
        }

        @Test("ExportedNutrient should handle floating point amounts")
        func testFloatingPointAmount() {
            // Arrange & Act
            let nutrient = ExportedNutrient(
                name: "Vitamin D",
                amount: 20.5,
                unit: "μg"
            )

            // Assert
            #expect(nutrient.amount == 20.5)
        }

        @Test("ExportedNutrient should encode and decode correctly")
        func testCodable() throws {
            // Arrange
            let original = ExportedNutrient(
                name: "Iron",
                amount: 15.0,
                unit: "mg"
            )

            // Act
            let encoder = JSONEncoder()
            let data = try encoder.encode(original)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ExportedNutrient.self, from: data)

            // Assert
            #expect(decoded.name == original.name)
            #expect(decoded.amount == original.amount)
            #expect(decoded.unit == original.unit)
        }
    }

    @Suite("ExportedSupplement Tests")
    struct ExportedSupplementTests {
        @Test("ExportedSupplement should initialize with all fields")
        func testInitialization() {
            // Arrange
            let nutrients = [
                ExportedNutrient(name: "Vitamin C", amount: 100, unit: "mg")
            ]

            // Act
            let supplement = ExportedSupplement(
                name: "Multi Vitamin",
                brand: "Brand A",
                servingSize: "1 tablet",
                servingsPerDay: 2,
                nutrients: nutrients,
                isActive: true
            )

            // Assert
            #expect(supplement.name == "Multi Vitamin")
            #expect(supplement.brand == "Brand A")
            #expect(supplement.servingSize == "1 tablet")
            #expect(supplement.servingsPerDay == 2)
            #expect(supplement.nutrients.count == 1)
            #expect(supplement.isActive == true)
        }

        @Test("ExportedSupplement should handle optional brand")
        func testOptionalBrand() {
            // Arrange & Act
            let supplement = ExportedSupplement(
                name: "Vitamin D",
                brand: nil,
                servingSize: "1 drop",
                servingsPerDay: 1,
                nutrients: [],
                isActive: true
            )

            // Assert
            #expect(supplement.brand == nil)
        }

        @Test("ExportedSupplement should encode and decode correctly")
        func testCodable() throws {
            // Arrange
            let nutrients = [
                ExportedNutrient(name: "Calcium", amount: 500, unit: "mg")
            ]
            let original = ExportedSupplement(
                name: "Calcium Supplement",
                brand: "Brand B",
                servingSize: "2 tablets",
                servingsPerDay: 1,
                nutrients: nutrients,
                isActive: false
            )

            // Act
            let encoder = JSONEncoder()
            let data = try encoder.encode(original)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ExportedSupplement.self, from: data)

            // Assert
            #expect(decoded.name == original.name)
            #expect(decoded.brand == original.brand)
            #expect(decoded.servingsPerDay == original.servingsPerDay)
            #expect(decoded.isActive == original.isActive)
        }
    }

    @Suite("ExportedIntakeRecord Tests")
    struct ExportedIntakeRecordTests {
        @Test("ExportedIntakeRecord should initialize correctly")
        func testInitialization() {
            // Arrange
            let date = Date()

            // Act
            let record = ExportedIntakeRecord(
                supplementName: "Vitamin D",
                date: date,
                timeOfDay: "Morning",
                servingsTaken: 1
            )

            // Assert
            #expect(record.supplementName == "Vitamin D")
            #expect(record.date == date)
            #expect(record.timeOfDay == "Morning")
            #expect(record.servingsTaken == 1)
        }

        @Test("ExportedIntakeRecord should handle multiple servings")
        func testMultipleServings() {
            // Arrange & Act
            let record = ExportedIntakeRecord(
                supplementName: "Multi",
                date: Date(),
                timeOfDay: "Evening",
                servingsTaken: 3
            )

            // Assert
            #expect(record.servingsTaken == 3)
        }
    }

    @Suite("ExportedReminder Tests")
    struct ExportedReminderTests {
        @Test("ExportedReminder should initialize correctly")
        func testInitialization() {
            // Arrange & Act
            let reminder = ExportedReminder(
                supplementName: "Vitamin C",
                time: "08:00",
                repeatMode: "Daily",
                isEnabled: true
            )

            // Assert
            #expect(reminder.supplementName == "Vitamin C")
            #expect(reminder.time == "08:00")
            #expect(reminder.repeatMode == "Daily")
            #expect(reminder.isEnabled == true)
        }

        @Test("ExportedReminder should handle disabled reminders")
        func testDisabledReminder() {
            // Arrange & Act
            let reminder = ExportedReminder(
                supplementName: "Test",
                time: "20:00",
                repeatMode: "Weekly",
                isEnabled: false
            )

            // Assert
            #expect(reminder.isEnabled == false)
        }
    }

    @Suite("ExportData Tests")
    struct ExportDataMainTests {
        @Test("ExportData should initialize with all components")
        func testInitialization() {
            // Arrange
            let exportDate = Date()
            let userProfile = ExportedUserProfile(
                name: "Test User",
                userType: "male",
                specialNeeds: nil
            )
            let supplements = [
                ExportedSupplement(
                    name: "Vitamin C",
                    brand: "Brand A",
                    servingSize: "1 tablet",
                    servingsPerDay: 1,
                    nutrients: [],
                    isActive: true
                )
            ]
            let intakeRecords: [ExportedIntakeRecord] = []
            let reminders: [ExportedReminder] = []

            // Act
            let exportData = ExportData(
                exportDate: exportDate,
                appVersion: "1.0.0",
                userProfile: userProfile,
                supplements: supplements,
                intakeRecords: intakeRecords,
                reminders: reminders
            )

            // Assert
            #expect(exportData.exportDate == exportDate)
            #expect(exportData.appVersion == "1.0.0")
            #expect(exportData.userProfile?.name == "Test User")
            #expect(exportData.supplements.count == 1)
            #expect(exportData.intakeRecords.isEmpty)
            #expect(exportData.reminders.isEmpty)
        }

        @Test("ExportData should handle nil user profile")
        func testNilUserProfile() {
            // Arrange & Act
            let exportData = ExportData(
                exportDate: Date(),
                appVersion: "1.0.0",
                userProfile: nil,
                supplements: [],
                intakeRecords: [],
                reminders: []
            )

            // Assert
            #expect(exportData.userProfile == nil)
        }

        @Test("ExportData should convert to JSON")
        func testToJSON() throws {
            // Arrange
            let userProfile = ExportedUserProfile(
                name: "Test",
                userType: "male",
                specialNeeds: nil
            )
            let exportData = ExportData(
                exportDate: Date(),
                appVersion: "1.0.0",
                userProfile: userProfile,
                supplements: [],
                intakeRecords: [],
                reminders: []
            )

            // Act
            let jsonData = try exportData.toJSON()

            // Assert
            #expect(jsonData.count > 0)

            // Verify it's valid JSON
            let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            #expect(json != nil)
            #expect(json?["appVersion"] as? String == "1.0.0")
        }

        @Test("ExportData JSON should be pretty printed")
        func testJSONPrettyPrint() throws {
            // Arrange
            let exportData = ExportData(
                exportDate: Date(),
                appVersion: "1.0.0",
                userProfile: nil,
                supplements: [],
                intakeRecords: [],
                reminders: []
            )

            // Act
            let jsonData = try exportData.toJSON()
            let jsonString = String(data: jsonData, encoding: .utf8)!

            // Assert - Pretty printed JSON should contain newlines
            #expect(jsonString.contains("\n"))
        }

        @Test("ExportData should convert to CSV")
        func testToCSV() {
            // Arrange
            let supplements = [
                ExportedSupplement(
                    name: "Vitamin C",
                    brand: "Brand A",
                    servingSize: "1 tablet",
                    servingsPerDay: 2,
                    nutrients: [
                        ExportedNutrient(name: "Vitamin C", amount: 100, unit: "mg")
                    ],
                    isActive: true
                ),
                ExportedSupplement(
                    name: "Vitamin D",
                    brand: nil,
                    servingSize: "1 drop",
                    servingsPerDay: 1,
                    nutrients: [
                        ExportedNutrient(name: "Vitamin D", amount: 20, unit: "μg")
                    ],
                    isActive: false
                )
            ]
            let exportData = ExportData(
                exportDate: Date(),
                appVersion: "1.0.0",
                userProfile: nil,
                supplements: supplements,
                intakeRecords: [],
                reminders: []
            )

            // Act
            let csv = exportData.toCSV()

            // Assert
            #expect(csv.contains("Name"))
            #expect(csv.contains("Brand"))
            #expect(csv.contains("Vitamin C"))
            #expect(csv.contains("Vitamin D"))
            #expect(csv.contains("Brand A"))
            #expect(csv.contains("1 tablet"))
            #expect(csv.contains("1 drop"))
        }

        @Test("CSV should have header row")
        func testCSVHeader() {
            // Arrange
            let exportData = ExportData(
                exportDate: Date(),
                appVersion: "1.0.0",
                userProfile: nil,
                supplements: [],
                intakeRecords: [],
                reminders: []
            )

            // Act
            let csv = exportData.toCSV()
            let lines = csv.components(separatedBy: "\n")

            // Assert
            #expect(lines.count > 0)
            #expect(lines[0].contains("Name"))
        }

        @Test("ExportData should encode and decode correctly")
        func testRoundTrip() throws {
            // Arrange
            let original = ExportData(
                exportDate: Date(timeIntervalSince1970: 1704067200), // Fixed date for comparison
                appVersion: "1.0.0",
                userProfile: ExportedUserProfile(
                    name: "Test",
                    userType: "female",
                    specialNeeds: "孕期"
                ),
                supplements: [
                    ExportedSupplement(
                        name: "Multi",
                        brand: "Brand A",
                        servingSize: "1 tablet",
                        servingsPerDay: 1,
                        nutrients: [
                            ExportedNutrient(name: "Vitamin C", amount: 100, unit: "mg")
                        ],
                        isActive: true
                    )
                ],
                intakeRecords: [],
                reminders: []
            )

            // Act
            let jsonData = try original.toJSON()
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode(ExportData.self, from: jsonData)

            // Assert
            #expect(decoded.appVersion == original.appVersion)
            #expect(decoded.userProfile?.name == original.userProfile?.name)
            #expect(decoded.supplements.count == original.supplements.count)
            #expect(decoded.supplements[0].name == "Multi")
        }
    }
}
