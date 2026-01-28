//
//  SpecialNeedsTests.swift
//  vitamin_calculatorTests
//
//  Created for Sprint 6 - Task 1.1
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("SpecialNeeds Enum Tests")
struct SpecialNeedsTests {

    @Suite("Case Tests")
    struct CaseTests {
        @Test("SpecialNeeds should have all required cases")
        func testAllCases() {
            // Arrange & Act
            let allCases = SpecialNeeds.allCases

            // Assert
            #expect(allCases.count == 4)
            #expect(allCases.contains(.none))
            #expect(allCases.contains(.pregnant))
            #expect(allCases.contains(.breastfeeding))
            #expect(allCases.contains(.pregnantAndBreastfeeding))
        }

        @Test("SpecialNeeds none case should have correct raw value")
        func testNoneCase() {
            // Arrange & Act
            let specialNeed = SpecialNeeds.none

            // Assert
            #expect(specialNeed.rawValue == "无")
        }

        @Test("SpecialNeeds pregnant case should have correct raw value")
        func testPregnantCase() {
            // Arrange & Act
            let specialNeed = SpecialNeeds.pregnant

            // Assert
            #expect(specialNeed.rawValue == "孕期")
        }

        @Test("SpecialNeeds breastfeeding case should have correct raw value")
        func testBreastfeedingCase() {
            // Arrange & Act
            let specialNeed = SpecialNeeds.breastfeeding

            // Assert
            #expect(specialNeed.rawValue == "哺乳期")
        }

        @Test("SpecialNeeds pregnantAndBreastfeeding case should have correct raw value")
        func testPregnantAndBreastfeedingCase() {
            // Arrange & Act
            let specialNeed = SpecialNeeds.pregnantAndBreastfeeding

            // Assert
            #expect(specialNeed.rawValue == "孕期及哺乳期")
        }
    }

    @Suite("Codable Tests")
    struct CodableTests {
        @Test("SpecialNeeds should encode to JSON")
        func testEncoding() throws {
            // Arrange
            let specialNeed = SpecialNeeds.pregnant

            // Act
            let encoder = JSONEncoder()
            let data = try encoder.encode(specialNeed)
            let jsonString = String(data: data, encoding: .utf8)

            // Assert
            #expect(jsonString?.contains("孕期") == true)
        }

        @Test("SpecialNeeds should decode from JSON")
        func testDecoding() throws {
            // Arrange
            let jsonString = "\"孕期\""
            let data = jsonString.data(using: .utf8)!

            // Act
            let decoder = JSONDecoder()
            let specialNeed = try decoder.decode(SpecialNeeds.self, from: data)

            // Assert
            #expect(specialNeed == .pregnant)
        }

        @Test("SpecialNeeds should encode and decode all cases")
        func testRoundTrip() throws {
            // Arrange
            let allCases = SpecialNeeds.allCases
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act & Assert
            for originalCase in allCases {
                let encoded = try encoder.encode(originalCase)
                let decoded = try decoder.decode(SpecialNeeds.self, from: encoded)
                #expect(decoded == originalCase)
            }
        }
    }

    @Suite("Equality Tests")
    struct EqualityTests {
        @Test("SpecialNeeds should compare equal cases correctly")
        func testEquality() {
            // Arrange
            let need1 = SpecialNeeds.pregnant
            let need2 = SpecialNeeds.pregnant

            // Act & Assert
            #expect(need1 == need2)
        }

        @Test("SpecialNeeds should compare different cases correctly")
        func testInequality() {
            // Arrange
            let need1 = SpecialNeeds.pregnant
            let need2 = SpecialNeeds.breastfeeding

            // Act & Assert
            #expect(need1 != need2)
        }
    }
}
