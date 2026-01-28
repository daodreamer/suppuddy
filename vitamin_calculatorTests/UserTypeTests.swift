//
//  UserTypeTests.swift
//  vitamin_calculatorTests
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("UserType Model Tests")
struct UserTypeTests {

    @Suite("Case Existence Tests")
    struct CaseExistenceTests {
        @Test("UserType should have male case")
        func testHasMale() {
            let male = UserType.male
            #expect(male != nil)
        }

        @Test("UserType should have female case")
        func testHasFemale() {
            let female = UserType.female
            #expect(female != nil)
        }

        @Test("UserType should have child case with age")
        func testHasChild() {
            let child = UserType.child(age: 10)
            #expect(child != nil)
        }
    }

    @Suite("Child Age Tests")
    struct ChildAgeTests {
        @Test("Child user type should store age correctly")
        func testChildUserTypeAge() {
            // Arrange & Act
            let child = UserType.child(age: 8)

            // Assert
            if case .child(let age) = child {
                #expect(age == 8)
            } else {
                Issue.record("Should be child type with age 8")
            }
        }

        @Test("Child user type should handle different ages")
        func testChildUserTypeDifferentAges() {
            // Test various ages
            let ages = [1, 5, 10, 15, 17]

            for testAge in ages {
                let child = UserType.child(age: testAge)

                if case .child(let age) = child {
                    #expect(age == testAge)
                } else {
                    Issue.record("Should be child type with age \(testAge)")
                }
            }
        }

        @Test("Child user type should handle infant age")
        func testChildInfantAge() {
            // Arrange & Act
            let infant = UserType.child(age: 0)

            // Assert
            if case .child(let age) = infant {
                #expect(age == 0)
            } else {
                Issue.record("Should be child type with age 0")
            }
        }

        @Test("Child user type should handle teenager age")
        func testChildTeenagerAge() {
            // Arrange & Act
            let teenager = UserType.child(age: 17)

            // Assert
            if case .child(let age) = teenager {
                #expect(age == 17)
            } else {
                Issue.record("Should be child type with age 17")
            }
        }
    }

    @Suite("Type Comparison Tests")
    struct TypeComparisonTests {
        @Test("Two male types should be equal")
        func testMaleEquality() {
            // Arrange
            let male1 = UserType.male
            let male2 = UserType.male

            // Assert
            #expect(male1 == male2)
        }

        @Test("Two female types should be equal")
        func testFemaleEquality() {
            // Arrange
            let female1 = UserType.female
            let female2 = UserType.female

            // Assert
            #expect(female1 == female2)
        }

        @Test("Two children with same age should be equal")
        func testChildEqualityWithSameAge() {
            // Arrange
            let child1 = UserType.child(age: 10)
            let child2 = UserType.child(age: 10)

            // Assert
            #expect(child1 == child2)
        }

        @Test("Two children with different ages should not be equal")
        func testChildInequalityWithDifferentAges() {
            // Arrange
            let child1 = UserType.child(age: 8)
            let child2 = UserType.child(age: 12)

            // Assert
            #expect(child1 != child2)
        }

        @Test("Male and female should not be equal")
        func testMaleFemaleInequality() {
            // Arrange
            let male = UserType.male
            let female = UserType.female

            // Assert
            #expect(male != female)
        }

        @Test("Adult and child should not be equal")
        func testAdultChildInequality() {
            // Arrange
            let adult = UserType.male
            let child = UserType.child(age: 10)

            // Assert
            #expect(adult != child)
        }
    }

    @Suite("Localized Description Tests")
    struct LocalizedDescriptionTests {
        @Test("Male should have localized description")
        func testMaleLocalizedDescription() {
            // Arrange
            let male = UserType.male

            // Act & Assert
            #expect(!male.localizedDescription.isEmpty)
        }

        @Test("Female should have localized description")
        func testFemaleLocalizedDescription() {
            // Arrange
            let female = UserType.female

            // Act & Assert
            #expect(!female.localizedDescription.isEmpty)
        }

        @Test("Child should have localized description with age")
        func testChildLocalizedDescription() {
            // Arrange
            let child = UserType.child(age: 10)

            // Act
            let description = child.localizedDescription

            // Assert
            #expect(!description.isEmpty)
            #expect(description.contains("10") || description.contains("child"))
        }

        @Test("Different child ages should have different descriptions")
        func testChildDescriptionIncludesAge() {
            // Arrange
            let child5 = UserType.child(age: 5)
            let child15 = UserType.child(age: 15)

            // Act
            let desc5 = child5.localizedDescription
            let desc15 = child15.localizedDescription

            // Assert - descriptions should be different
            #expect(desc5 != desc15)
        }
    }

    @Suite("Codable Tests")
    struct CodableTests {
        @Test("Male should be encodable and decodable")
        func testMaleCodable() throws {
            // Arrange
            let original = UserType.male
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(UserType.self, from: data)

            // Assert
            #expect(decoded == original)
        }

        @Test("Female should be encodable and decodable")
        func testFemaleCodable() throws {
            // Arrange
            let original = UserType.female
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(UserType.self, from: data)

            // Assert
            #expect(decoded == original)
        }

        @Test("Child should be encodable and decodable")
        func testChildCodable() throws {
            // Arrange
            let original = UserType.child(age: 12)
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(UserType.self, from: data)

            // Assert
            #expect(decoded == original)
        }

        @Test("All user types should round-trip encode and decode")
        func testAllUserTypesRoundTrip() throws {
            // Arrange
            let userTypes: [UserType] = [
                .male,
                .female,
                .child(age: 5),
                .child(age: 15)
            ]
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act & Assert
            for userType in userTypes {
                let data = try encoder.encode(userType)
                let decoded = try decoder.decode(UserType.self, from: data)
                #expect(decoded == userType)
            }
        }
    }
}
