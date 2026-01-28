//
//  DailyRecommendationTests.swift
//  vitamin_calculatorTests
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("DailyRecommendation Model Tests")
struct DailyRecommendationTests {

    @Suite("Initialization Tests")
    struct InitializationTests {
        @Test("DailyRecommendation should initialize with all properties")
        func testBasicInitialization() {
            // Arrange & Act
            let recommendation = DailyRecommendation(
                nutrientType: .vitaminC,
                recommendedAmount: 100.0,
                upperLimit: 2000.0,
                userType: .male
            )

            // Assert
            #expect(recommendation.nutrientType == .vitaminC)
            #expect(recommendation.recommendedAmount == 100.0)
            #expect(recommendation.upperLimit == 2000.0)
            #expect(recommendation.userType == .male)
        }

        @Test("DailyRecommendation should handle nutrients without upper limit")
        func testRecommendationWithoutUpperLimit() {
            // Arrange & Act
            let recommendation = DailyRecommendation(
                nutrientType: .vitaminC,
                recommendedAmount: 100.0,
                upperLimit: nil,
                userType: .male
            )

            // Assert
            #expect(recommendation.upperLimit == nil)
            #expect(recommendation.recommendedAmount == 100.0)
        }

        @Test("DailyRecommendation should work with all nutrient types")
        func testAllNutrientTypes() {
            // Test a few representative nutrients
            let recommendations = [
                DailyRecommendation(nutrientType: .vitaminA, recommendedAmount: 800.0, upperLimit: 3000.0, userType: .male),
                DailyRecommendation(nutrientType: .calcium, recommendedAmount: 1000.0, upperLimit: 2500.0, userType: .female),
                DailyRecommendation(nutrientType: .iron, recommendedAmount: 10.0, upperLimit: 45.0, userType: .child(age: 10))
            ]

            #expect(recommendations.count == 3)
            #expect(recommendations[0].nutrientType == .vitaminA)
            #expect(recommendations[1].nutrientType == .calcium)
            #expect(recommendations[2].nutrientType == .iron)
        }
    }

    @Suite("Property Tests")
    struct PropertyTests {
        @Test("DailyRecommendation should have correct recommended amount")
        func testRecommendedAmount() {
            // Arrange
            let recommendation = DailyRecommendation(
                nutrientType: .vitaminD,
                recommendedAmount: 20.0,
                upperLimit: 100.0,
                userType: .male
            )

            // Assert
            #expect(recommendation.recommendedAmount == 20.0)
        }

        @Test("DailyRecommendation should have correct upper limit")
        func testUpperLimit() {
            // Arrange
            let recommendation = DailyRecommendation(
                nutrientType: .zinc,
                recommendedAmount: 10.0,
                upperLimit: 40.0,
                userType: .female
            )

            // Assert
            #expect(recommendation.upperLimit == 40.0)
        }

        @Test("DailyRecommendation should handle zero recommended amount")
        func testZeroRecommendedAmount() {
            // Arrange & Act
            let recommendation = DailyRecommendation(
                nutrientType: .vitaminC,
                recommendedAmount: 0.0,
                upperLimit: 1000.0,
                userType: .male
            )

            // Assert
            #expect(recommendation.recommendedAmount == 0.0)
        }
    }

    @Suite("User Type Tests")
    struct UserTypeTests {
        @Test("DailyRecommendation should support male user type")
        func testMaleUserType() {
            // Arrange & Act
            let recommendation = DailyRecommendation(
                nutrientType: .vitaminC,
                recommendedAmount: 110.0,
                upperLimit: 2000.0,
                userType: .male
            )

            // Assert
            #expect(recommendation.userType == .male)
        }

        @Test("DailyRecommendation should support female user type")
        func testFemaleUserType() {
            // Arrange & Act
            let recommendation = DailyRecommendation(
                nutrientType: .vitaminC,
                recommendedAmount: 95.0,
                upperLimit: 2000.0,
                userType: .female
            )

            // Assert
            #expect(recommendation.userType == .female)
        }

        @Test("DailyRecommendation should support child user type")
        func testChildUserType() {
            // Arrange & Act
            let recommendation = DailyRecommendation(
                nutrientType: .vitaminC,
                recommendedAmount: 65.0,
                upperLimit: 1200.0,
                userType: .child(age: 10)
            )

            // Assert
            if case .child(let age) = recommendation.userType {
                #expect(age == 10)
            } else {
                Issue.record("UserType should be child")
            }
        }
    }

    @Suite("Codable Tests")
    struct CodableTests {
        @Test("DailyRecommendation should be encodable")
        func testEncoding() throws {
            // Arrange
            let recommendation = DailyRecommendation(
                nutrientType: .vitaminC,
                recommendedAmount: 100.0,
                upperLimit: 2000.0,
                userType: .male
            )
            let encoder = JSONEncoder()

            // Act
            let data = try encoder.encode(recommendation)

            // Assert
            #expect(!data.isEmpty)
        }

        @Test("DailyRecommendation should be decodable")
        func testDecoding() throws {
            // Arrange
            let original = DailyRecommendation(
                nutrientType: .calcium,
                recommendedAmount: 1000.0,
                upperLimit: 2500.0,
                userType: .female
            )
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(DailyRecommendation.self, from: data)

            // Assert
            #expect(decoded.nutrientType == original.nutrientType)
            #expect(decoded.recommendedAmount == original.recommendedAmount)
            #expect(decoded.upperLimit == original.upperLimit)
            #expect(decoded.userType == original.userType)
        }

        @Test("DailyRecommendation with nil upper limit should round-trip")
        func testRoundTripWithNilUpperLimit() throws {
            // Arrange
            let original = DailyRecommendation(
                nutrientType: .vitaminB12,
                recommendedAmount: 4.0,
                upperLimit: nil,
                userType: .male
            )
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // Act
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(DailyRecommendation.self, from: data)

            // Assert
            #expect(decoded.nutrientType == original.nutrientType)
            #expect(decoded.recommendedAmount == original.recommendedAmount)
            #expect(decoded.upperLimit == nil)
            #expect(decoded.userType == original.userType)
        }
    }

    @Suite("Edge Case Tests")
    struct EdgeCaseTests {
        @Test("DailyRecommendation should handle very small amounts")
        func testVerySmallAmounts() {
            // Arrange & Act
            let recommendation = DailyRecommendation(
                nutrientType: .vitaminB12,
                recommendedAmount: 0.001,
                upperLimit: 0.01,
                userType: .child(age: 1)
            )

            // Assert
            #expect(recommendation.recommendedAmount == 0.001)
            #expect(recommendation.upperLimit == 0.01)
        }

        @Test("DailyRecommendation should handle large amounts")
        func testLargeAmounts() {
            // Arrange & Act
            let recommendation = DailyRecommendation(
                nutrientType: .calcium,
                recommendedAmount: 1300.0,
                upperLimit: 3000.0,
                userType: .male
            )

            // Assert
            #expect(recommendation.recommendedAmount == 1300.0)
            #expect(recommendation.upperLimit == 3000.0)
        }
    }
}
