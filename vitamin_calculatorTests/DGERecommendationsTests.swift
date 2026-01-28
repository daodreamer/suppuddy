//
//  DGERecommendationsTests.swift
//  vitamin_calculatorTests
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("DGERecommendations Data Tests")
struct DGERecommendationsTests {

    @Suite("Data Completeness Tests")
    struct CompletenessTests {
        @Test("DGE data should have recommendations for all nutrients and adult male")
        func testAdultMaleCompleteness() {
            // Arrange
            let allNutrients = NutrientType.allCases

            // Act & Assert
            for nutrient in allNutrients {
                let recommendation = DGERecommendations.getRecommendation(
                    for: nutrient,
                    userType: .male
                )
                #expect(recommendation != nil, "Missing recommendation for \(nutrient) - male")
            }
        }

        @Test("DGE data should have recommendations for all nutrients and adult female")
        func testAdultFemaleCompleteness() {
            // Arrange
            let allNutrients = NutrientType.allCases

            // Act & Assert
            for nutrient in allNutrients {
                let recommendation = DGERecommendations.getRecommendation(
                    for: nutrient,
                    userType: .female
                )
                #expect(recommendation != nil, "Missing recommendation for \(nutrient) - female")
            }
        }

        @Test("DGE data should have recommendations for children")
        func testChildCompleteness() {
            // Arrange
            let allNutrients = NutrientType.allCases
            let testAges = [7, 10, 13, 15]

            // Act & Assert
            for age in testAges {
                for nutrient in allNutrients {
                    let recommendation = DGERecommendations.getRecommendation(
                        for: nutrient,
                        userType: .child(age: age)
                    )
                    #expect(recommendation != nil, "Missing recommendation for \(nutrient) - child age \(age)")
                }
            }
        }
    }

    @Suite("Specific Value Tests")
    struct SpecificValueTests {
        @Test("Vitamin C recommendation for adult male should match DGE standard")
        func testVitaminCMale() {
            // Arrange & Act
            let recommendation = DGERecommendations.getRecommendation(
                for: .vitaminC,
                userType: .male
            )

            // Assert - DGE recommends 110 mg for adult males
            #expect(recommendation?.recommendedAmount == 110.0)
            #expect(recommendation?.nutrientType == .vitaminC)
        }

        @Test("Vitamin C recommendation for adult female should match DGE standard")
        func testVitaminCFemale() {
            // Arrange & Act
            let recommendation = DGERecommendations.getRecommendation(
                for: .vitaminC,
                userType: .female
            )

            // Assert - DGE recommends 95 mg for adult females
            #expect(recommendation?.recommendedAmount == 95.0)
        }

        @Test("Vitamin D recommendation for adults should match DGE standard")
        func testVitaminDAdult() {
            // Arrange & Act
            let maleDRec = DGERecommendations.getRecommendation(
                for: .vitaminD,
                userType: .male
            )
            let femaleDRec = DGERecommendations.getRecommendation(
                for: .vitaminD,
                userType: .female
            )

            // Assert - DGE recommends 20 μg for adults
            #expect(maleDRec?.recommendedAmount == 20.0)
            #expect(femaleDRec?.recommendedAmount == 20.0)
        }

        @Test("Calcium recommendation for adults should match DGE standard")
        func testCalciumAdult() {
            // Arrange & Act
            let maleRec = DGERecommendations.getRecommendation(
                for: .calcium,
                userType: .male
            )
            let femaleRec = DGERecommendations.getRecommendation(
                for: .calcium,
                userType: .female
            )

            // Assert - DGE recommends 1000 mg for adults
            #expect(maleRec?.recommendedAmount == 1000.0)
            #expect(femaleRec?.recommendedAmount == 1000.0)
        }
    }

    @Suite("Upper Limit Tests")
    struct UpperLimitTests {
        @Test("Nutrients should have upper limits when applicable")
        func testUpperLimitsExist() {
            // Arrange - nutrients that typically have upper limits
            let nutrientsWithLimits: [NutrientType] = [
                .vitaminA, .vitaminD, .vitaminE,
                .calcium, .iron, .zinc
            ]

            // Act & Assert
            for nutrient in nutrientsWithLimits {
                let recommendation = DGERecommendations.getRecommendation(
                    for: nutrient,
                    userType: .male
                )
                #expect(recommendation?.upperLimit != nil, "\(nutrient) should have upper limit")
            }
        }

        @Test("Vitamin C upper limit should be set correctly")
        func testVitaminCUpperLimit() {
            // Arrange & Act
            let recommendation = DGERecommendations.getRecommendation(
                for: .vitaminC,
                userType: .male
            )

            // Assert - upper limit is typically around 2000 mg
            #expect(recommendation?.upperLimit != nil)
            #expect(recommendation?.upperLimit ?? 0 > 1000.0)
        }
    }

    @Suite("Age-Based Recommendations Tests")
    struct AgeBasedTests {
        @Test("Children should have different recommendations than adults")
        func testChildVsAdultDifference() {
            // Arrange
            let child = UserType.child(age: 7)
            let adult = UserType.male

            // Act
            let childVitaminC = DGERecommendations.getRecommendation(
                for: .vitaminC,
                userType: child
            )
            let adultVitaminC = DGERecommendations.getRecommendation(
                for: .vitaminC,
                userType: adult
            )

            // Assert - children typically need less than adults
            #expect(childVitaminC?.recommendedAmount ?? 0 < adultVitaminC?.recommendedAmount ?? 0)
        }

        @Test("Older children should have higher recommendations than younger children")
        func testAgeProgression() {
            // Arrange
            let youngerChild = UserType.child(age: 4)
            let olderChild = UserType.child(age: 13)

            // Act
            let youngerRec = DGERecommendations.getRecommendation(
                for: .calcium,
                userType: youngerChild
            )
            let olderRec = DGERecommendations.getRecommendation(
                for: .calcium,
                userType: olderChild
            )

            // Assert - older children typically need more calcium
            #expect(olderRec?.recommendedAmount ?? 0 >= youngerRec?.recommendedAmount ?? 0)
        }
    }

    @Suite("Return Value Tests")
    struct ReturnValueTests {
        @Test("getRecommendation should return correct user type")
        func testReturnedUserType() {
            // Arrange & Act
            let recommendation = DGERecommendations.getRecommendation(
                for: .vitaminC,
                userType: .female
            )

            // Assert
            #expect(recommendation?.userType == .female)
        }

        @Test("getRecommendation should return correct nutrient type")
        func testReturnedNutrientType() {
            // Arrange & Act
            let recommendation = DGERecommendations.getRecommendation(
                for: .zinc,
                userType: .male
            )

            // Assert
            #expect(recommendation?.nutrientType == .zinc)
        }

        @Test("Recommendations should have positive amounts")
        func testPositiveAmounts() {
            // Arrange
            let nutrients = NutrientType.allCases

            // Act & Assert
            for nutrient in nutrients {
                let recommendation = DGERecommendations.getRecommendation(
                    for: nutrient,
                    userType: .male
                )
                #expect(recommendation?.recommendedAmount ?? 0 > 0, "\(nutrient) should have positive recommended amount")
            }
        }
    }

    @Suite("All Recommendations Tests")
    struct AllRecommendationsTests {
        @Test("getAllRecommendations should return all nutrients for male")
        func testGetAllRecommendationsMale() {
            // Arrange & Act
            let recommendations = DGERecommendations.getAllRecommendations(for: .male)

            // Assert
            #expect(recommendations.count == NutrientType.allCases.count)
        }

        @Test("getAllRecommendations should return all nutrients for female")
        func testGetAllRecommendationsFemale() {
            // Arrange & Act
            let recommendations = DGERecommendations.getAllRecommendations(for: .female)

            // Assert
            #expect(recommendations.count == NutrientType.allCases.count)
        }

        @Test("getAllRecommendations should return all nutrients for children")
        func testGetAllRecommendationsChild() {
            // Arrange & Act
            let recommendations = DGERecommendations.getAllRecommendations(for: .child(age: 10))

            // Assert
            #expect(recommendations.count == NutrientType.allCases.count)
        }

        @Test("getAllRecommendations should have no duplicates")
        func testNoDuplicates() {
            // Arrange & Act
            let recommendations = DGERecommendations.getAllRecommendations(for: .male)
            let nutrientTypes = recommendations.map { $0.nutrientType }
            let uniqueTypes = Set(nutrientTypes)

            // Assert
            #expect(nutrientTypes.count == uniqueTypes.count)
        }
    }
}
