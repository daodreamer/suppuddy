//
//  ChildAgeGroupTests.swift
//  vitamin_calculatorTests
//
//  Created for Sprint 6 - Task 1.1
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("ChildAgeGroup Enum Tests")
struct ChildAgeGroupTests {

    @Suite("Case Tests")
    struct CaseTests {
        @Test("ChildAgeGroup should have all required cases")
        func testAllCases() {
            // Arrange & Act
            let allCases = ChildAgeGroup.allCases

            // Assert
            #expect(allCases.count == 6)
            #expect(allCases.contains(.age1to3))
            #expect(allCases.contains(.age4to6))
            #expect(allCases.contains(.age7to9))
            #expect(allCases.contains(.age10to12))
            #expect(allCases.contains(.age13to14))
            #expect(allCases.contains(.age15to18))
        }

        @Test("ChildAgeGroup age1to3 should have correct raw value")
        func testAge1to3Case() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.age1to3

            // Assert
            #expect(ageGroup.rawValue == "1-3岁")
        }

        @Test("ChildAgeGroup age4to6 should have correct raw value")
        func testAge4to6Case() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.age4to6

            // Assert
            #expect(ageGroup.rawValue == "4-6岁")
        }

        @Test("ChildAgeGroup age7to9 should have correct raw value")
        func testAge7to9Case() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.age7to9

            // Assert
            #expect(ageGroup.rawValue == "7-9岁")
        }

        @Test("ChildAgeGroup age10to12 should have correct raw value")
        func testAge10to12Case() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.age10to12

            // Assert
            #expect(ageGroup.rawValue == "10-12岁")
        }

        @Test("ChildAgeGroup age13to14 should have correct raw value")
        func testAge13to14Case() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.age13to14

            // Assert
            #expect(ageGroup.rawValue == "13-14岁")
        }

        @Test("ChildAgeGroup age15to18 should have correct raw value")
        func testAge15to18Case() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.age15to18

            // Assert
            #expect(ageGroup.rawValue == "15-18岁")
        }
    }

    @Suite("Age Range Tests")
    struct AgeRangeTests {
        @Test("age1to3 should have correct age range")
        func testAge1to3Range() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.age1to3

            // Assert
            #expect(ageGroup.ageRange == 1...3)
            #expect(ageGroup.ageRange.contains(1))
            #expect(ageGroup.ageRange.contains(2))
            #expect(ageGroup.ageRange.contains(3))
        }

        @Test("age4to6 should have correct age range")
        func testAge4to6Range() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.age4to6

            // Assert
            #expect(ageGroup.ageRange == 4...6)
        }

        @Test("age7to9 should have correct age range")
        func testAge7to9Range() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.age7to9

            // Assert
            #expect(ageGroup.ageRange == 7...9)
        }

        @Test("age10to12 should have correct age range")
        func testAge10to12Range() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.age10to12

            // Assert
            #expect(ageGroup.ageRange == 10...12)
        }

        @Test("age13to14 should have correct age range")
        func testAge13to14Range() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.age13to14

            // Assert
            #expect(ageGroup.ageRange == 13...14)
        }

        @Test("age15to18 should have correct age range")
        func testAge15to18Range() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.age15to18

            // Assert
            #expect(ageGroup.ageRange == 15...18)
        }
    }

    @Suite("Factory Method Tests")
    struct FactoryMethodTests {
        @Test("from(age:) should return correct age group for age 2")
        func testFromAge2() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.from(age: 2)

            // Assert
            #expect(ageGroup == .age1to3)
        }

        @Test("from(age:) should return correct age group for age 5")
        func testFromAge5() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.from(age: 5)

            // Assert
            #expect(ageGroup == .age4to6)
        }

        @Test("from(age:) should return correct age group for age 8")
        func testFromAge8() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.from(age: 8)

            // Assert
            #expect(ageGroup == .age7to9)
        }

        @Test("from(age:) should return correct age group for age 11")
        func testFromAge11() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.from(age: 11)

            // Assert
            #expect(ageGroup == .age10to12)
        }

        @Test("from(age:) should return correct age group for age 14")
        func testFromAge14() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.from(age: 14)

            // Assert
            #expect(ageGroup == .age13to14)
        }

        @Test("from(age:) should return correct age group for age 17")
        func testFromAge17() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.from(age: 17)

            // Assert
            #expect(ageGroup == .age15to18)
        }

        @Test("from(age:) should return nil for age 0")
        func testFromAge0() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.from(age: 0)

            // Assert
            #expect(ageGroup == nil)
        }

        @Test("from(age:) should return nil for age 19")
        func testFromAge19() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.from(age: 19)

            // Assert
            #expect(ageGroup == nil)
        }

        @Test("from(age:) should return nil for negative age")
        func testFromNegativeAge() {
            // Arrange & Act
            let ageGroup = ChildAgeGroup.from(age: -5)

            // Assert
            #expect(ageGroup == nil)
        }

        @Test("from(age:) should handle boundary ages correctly")
        func testBoundaryAges() {
            // Test lower boundaries
            #expect(ChildAgeGroup.from(age: 1) == .age1to3)
            #expect(ChildAgeGroup.from(age: 4) == .age4to6)
            #expect(ChildAgeGroup.from(age: 7) == .age7to9)
            #expect(ChildAgeGroup.from(age: 10) == .age10to12)
            #expect(ChildAgeGroup.from(age: 13) == .age13to14)
            #expect(ChildAgeGroup.from(age: 15) == .age15to18)

            // Test upper boundaries
            #expect(ChildAgeGroup.from(age: 3) == .age1to3)
            #expect(ChildAgeGroup.from(age: 6) == .age4to6)
            #expect(ChildAgeGroup.from(age: 9) == .age7to9)
            #expect(ChildAgeGroup.from(age: 12) == .age10to12)
            #expect(ChildAgeGroup.from(age: 14) == .age13to14)
            #expect(ChildAgeGroup.from(age: 18) == .age15to18)
        }
    }

    @Suite("Codable Tests")
    struct CodableTests {
        @Test("ChildAgeGroup should encode to JSON")
        func testEncoding() throws {
            // Arrange
            let ageGroup = ChildAgeGroup.age7to9

            // Act
            let encoder = JSONEncoder()
            let data = try encoder.encode(ageGroup)
            let jsonString = String(data: data, encoding: .utf8)

            // Assert
            #expect(jsonString?.contains("7-9岁") == true)
        }

        @Test("ChildAgeGroup should decode from JSON")
        func testDecoding() throws {
            // Arrange
            let jsonString = "\"7-9岁\""
            let data = jsonString.data(using: .utf8)!

            // Act
            let decoder = JSONDecoder()
            let ageGroup = try decoder.decode(ChildAgeGroup.self, from: data)

            // Assert
            #expect(ageGroup == .age7to9)
        }

        @Test("ChildAgeGroup should encode and decode all cases")
        func testRoundTrip() throws {
            // Arrange
            let allCases = ChildAgeGroup.allCases
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act & Assert
            for originalCase in allCases {
                let encoded = try encoder.encode(originalCase)
                let decoded = try decoder.decode(ChildAgeGroup.self, from: encoded)
                #expect(decoded == originalCase)
            }
        }
    }
}
