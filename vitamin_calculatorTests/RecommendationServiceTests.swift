//
//  RecommendationServiceTests.swift
//  vitamin_calculatorTests
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Foundation
import Testing
@testable import vitamin_calculator

@Suite("RecommendationService Tests")
struct RecommendationServiceTests {

    @Suite("Single Recommendation Tests")
    struct SingleRecommendationTests {
        @Test("Service should return correct recommendation for male user")
        func testGetRecommendationMale() {
            // Arrange
            let service = RecommendationService()
            let user = UserProfile(name: "Test User", userType: .male)

            // Act
            let recommendation = service.getRecommendation(for: .vitaminC, user: user)

            // Assert
            #expect(recommendation != nil)
            #expect(recommendation?.nutrientType == .vitaminC)
            #expect(recommendation?.userType == .male)
            #expect(recommendation?.recommendedAmount == 110.0)
        }

        @Test("Service should return correct recommendation for female user")
        func testGetRecommendationFemale() {
            // Arrange
            let service = RecommendationService()
            let user = UserProfile(name: "Test User", userType: .female)

            // Act
            let recommendation = service.getRecommendation(for: .vitaminC, user: user)

            // Assert
            #expect(recommendation != nil)
            #expect(recommendation?.nutrientType == .vitaminC)
            #expect(recommendation?.userType == .female)
            #expect(recommendation?.recommendedAmount == 95.0)
        }

        @Test("Service should return correct recommendation for child")
        func testGetRecommendationChild() {
            // Arrange
            let service = RecommendationService()
            let user = UserProfile(name: "Child", userType: .child(age: 10))

            // Act
            let recommendation = service.getRecommendation(for: .vitaminD, user: user)

            // Assert
            #expect(recommendation != nil)
            #expect(recommendation?.nutrientType == .vitaminD)
            if case .child(let age) = recommendation?.userType {
                #expect(age == 10)
            } else {
                Issue.record("UserType should be child with age 10")
            }
        }

        @Test("Service should return recommendation with upper limit when applicable")
        func testRecommendationWithUpperLimit() {
            // Arrange
            let service = RecommendationService()
            let user = UserProfile(name: "Test", userType: .male)

            // Act
            let recommendation = service.getRecommendation(for: .vitaminC, user: user)

            // Assert
            #expect(recommendation?.upperLimit != nil)
            #expect(recommendation?.upperLimit == 2000.0)
        }
    }

    @Suite("All Recommendations Tests")
    struct AllRecommendationsTests {
        @Test("Service should return all recommendations for male user")
        func testGetAllRecommendationsMale() {
            // Arrange
            let service = RecommendationService()
            let user = UserProfile(name: "Male User", userType: .male)

            // Act
            let recommendations = service.getAllRecommendations(for: user)

            // Assert
            #expect(recommendations.count == NutrientType.allCases.count)
            #expect(recommendations.count == 23)
        }

        @Test("Service should return all recommendations for female user")
        func testGetAllRecommendationsFemale() {
            // Arrange
            let service = RecommendationService()
            let user = UserProfile(name: "Female User", userType: .female)

            // Act
            let recommendations = service.getAllRecommendations(for: user)

            // Assert
            #expect(recommendations.count == NutrientType.allCases.count)
        }

        @Test("Service should return all recommendations for child")
        func testGetAllRecommendationsChild() {
            // Arrange
            let service = RecommendationService()
            let user = UserProfile(name: "Child", userType: .child(age: 12))

            // Act
            let recommendations = service.getAllRecommendations(for: user)

            // Assert
            #expect(recommendations.count == NutrientType.allCases.count)
        }

        @Test("All recommendations should have matching user types")
        func testAllRecommendationsMatchUserType() {
            // Arrange
            let service = RecommendationService()
            let user = UserProfile(name: "Test", userType: .female)

            // Act
            let recommendations = service.getAllRecommendations(for: user)

            // Assert
            for recommendation in recommendations {
                #expect(recommendation.userType == .female)
            }
        }

        @Test("All recommendations should have positive amounts")
        func testAllRecommendationsPositiveAmounts() {
            // Arrange
            let service = RecommendationService()
            let user = UserProfile(name: "Test", userType: .male)

            // Act
            let recommendations = service.getAllRecommendations(for: user)

            // Assert
            for recommendation in recommendations {
                #expect(recommendation.recommendedAmount > 0,
                       "\(recommendation.nutrientType) should have positive amount")
            }
        }
    }

    @Suite("Edge Case Tests")
    struct EdgeCaseTests {
        @Test("Service should handle different child ages")
        func testDifferentChildAges() {
            // Arrange
            let service = RecommendationService()
            let ages = [4, 7, 10, 13, 16]

            // Act & Assert
            for age in ages {
                let user = UserProfile(name: "Child", userType: .child(age: age))
                let recommendation = service.getRecommendation(for: .calcium, user: user)

                #expect(recommendation != nil, "Should have recommendation for age \(age)")
                #expect(recommendation?.recommendedAmount ?? 0 > 0)
            }
        }

        @Test("Service should return different values for different ages")
        func testAgeDifferentiation() {
            // Arrange
            let service = RecommendationService()
            let youngChild = UserProfile(name: "Young", userType: .child(age: 4))
            let olderChild = UserProfile(name: "Older", userType: .child(age: 13))

            // Act
            let youngRec = service.getRecommendation(for: .calcium, user: youngChild)
            let olderRec = service.getRecommendation(for: .calcium, user: olderChild)

            // Assert - older children typically need more calcium
            #expect(olderRec?.recommendedAmount ?? 0 > youngRec?.recommendedAmount ?? 0)
        }

        @Test("Service should handle all nutrient types")
        func testAllNutrientTypes() {
            // Arrange
            let service = RecommendationService()
            let user = UserProfile(name: "Test", userType: .male)

            // Act & Assert
            for nutrient in NutrientType.allCases {
                let recommendation = service.getRecommendation(for: nutrient, user: user)
                #expect(recommendation != nil, "Should have recommendation for \(nutrient)")
                #expect(recommendation?.nutrientType == nutrient)
            }
        }
    }

    @Suite("Consistency Tests")
    struct ConsistencyTests {
        @Test("Service should return same recommendation for same input")
        func testConsistency() {
            // Arrange
            let service = RecommendationService()
            let user = UserProfile(name: "Test", userType: .male)

            // Act
            let rec1 = service.getRecommendation(for: .vitaminC, user: user)
            let rec2 = service.getRecommendation(for: .vitaminC, user: user)

            // Assert
            #expect(rec1?.recommendedAmount == rec2?.recommendedAmount)
            #expect(rec1?.upperLimit == rec2?.upperLimit)
            #expect(rec1?.nutrientType == rec2?.nutrientType)
        }

        @Test("getAllRecommendations should include all nutrients")
        func testGetAllIncludesAllNutrients() {
            // Arrange
            let service = RecommendationService()
            let user = UserProfile(name: "Test", userType: .male)

            // Act
            let recommendations = service.getAllRecommendations(for: user)
            let nutrientTypes = Set(recommendations.map { $0.nutrientType })

            // Assert
            #expect(nutrientTypes.count == NutrientType.allCases.count)
            for nutrient in NutrientType.allCases {
                #expect(nutrientTypes.contains(nutrient),
                       "Missing nutrient: \(nutrient)")
            }
        }
    }

    @Suite("Integration Tests")
    struct IntegrationTests {
        @Test("Service should work with DGERecommendations data")
        func testIntegrationWithDGE() {
            // Arrange
            let service = RecommendationService()
            let user = UserProfile(name: "Test", userType: .male)

            // Act
            let serviceRec = service.getRecommendation(for: .vitaminC, user: user)
            let dgeRec = DGERecommendations.getRecommendation(for: .vitaminC, userType: .male)

            // Assert - service should return same data as DGE
            #expect(serviceRec?.recommendedAmount == dgeRec?.recommendedAmount)
            #expect(serviceRec?.upperLimit == dgeRec?.upperLimit)
        }
    }

    @Suite("Special Needs Tests - Sprint 6 Task 3.1")
    struct SpecialNeedsTests {
        @Test("Service should return higher folate recommendation for pregnant user")
        func testPregnantFolateRecommendation() {
            // Arrange
            let service = RecommendationService()
            let normalUser = UserProfile(name: "Normal", userType: .female)
            let pregnantUser = UserProfile(name: "Pregnant", userType: .female)
            pregnantUser.specialNeeds = .pregnant

            // Act
            let normalRec = service.getRecommendation(for: .folate, user: normalUser)
            let pregnantRec = service.getRecommendation(for: .folate, user: pregnantUser)

            // Assert
            #expect(pregnantRec != nil, "Pregnant user should have folate recommendation")
            #expect(normalRec != nil, "Normal user should have folate recommendation")
            #expect(pregnantRec?.recommendedAmount ?? 0 > normalRec?.recommendedAmount ?? 0,
                   "Pregnant recommendation should be higher than normal")
            #expect(pregnantRec?.recommendedAmount == 550.0,
                   "Pregnant folate recommendation should be 550 μg")
        }

        @Test("Service should return higher iron recommendation for pregnant user")
        func testPregnantIronRecommendation() {
            // Arrange
            let service = RecommendationService()
            let normalUser = UserProfile(name: "Normal", userType: .female)
            let pregnantUser = UserProfile(name: "Pregnant", userType: .female)
            pregnantUser.specialNeeds = .pregnant

            // Act
            let normalRec = service.getRecommendation(for: .iron, user: normalUser)
            let pregnantRec = service.getRecommendation(for: .iron, user: pregnantUser)

            // Assert
            #expect(pregnantRec != nil)
            #expect(normalRec != nil)
            #expect(pregnantRec?.recommendedAmount ?? 0 > normalRec?.recommendedAmount ?? 0)
            #expect(pregnantRec?.recommendedAmount == 30.0,
                   "Pregnant iron recommendation should be 30 mg")
        }

        @Test("Service should return higher iodine recommendation for pregnant user")
        func testPregnantIodineRecommendation() {
            // Arrange
            let service = RecommendationService()
            let normalUser = UserProfile(name: "Normal", userType: .female)
            let pregnantUser = UserProfile(name: "Pregnant", userType: .female)
            pregnantUser.specialNeeds = .pregnant

            // Act
            let normalRec = service.getRecommendation(for: .iodine, user: normalUser)
            let pregnantRec = service.getRecommendation(for: .iodine, user: pregnantUser)

            // Assert
            #expect(pregnantRec != nil)
            #expect(normalRec != nil)
            #expect(pregnantRec?.recommendedAmount ?? 0 > normalRec?.recommendedAmount ?? 0)
            #expect(pregnantRec?.recommendedAmount == 220.0,
                   "Pregnant iodine recommendation should be 220 μg (DGE 2025/2026 update)")
        }

        @Test("Service should return higher folate recommendation for breastfeeding user")
        func testBreastfeedingFolateRecommendation() {
            // Arrange
            let service = RecommendationService()
            let normalUser = UserProfile(name: "Normal", userType: .female)
            let breastfeedingUser = UserProfile(name: "Breastfeeding", userType: .female)
            breastfeedingUser.specialNeeds = .breastfeeding

            // Act
            let normalRec = service.getRecommendation(for: .folate, user: normalUser)
            let breastfeedingRec = service.getRecommendation(for: .folate, user: breastfeedingUser)

            // Assert
            #expect(breastfeedingRec != nil)
            #expect(normalRec != nil)
            #expect(breastfeedingRec?.recommendedAmount ?? 0 > normalRec?.recommendedAmount ?? 0)
            #expect(breastfeedingRec?.recommendedAmount == 450.0,
                   "Breastfeeding folate recommendation should be 450 μg")
        }

        @Test("Service should return higher iron recommendation for breastfeeding user")
        func testBreastfeedingIronRecommendation() {
            // Arrange
            let service = RecommendationService()
            let normalUser = UserProfile(name: "Normal", userType: .female)
            let breastfeedingUser = UserProfile(name: "Breastfeeding", userType: .female)
            breastfeedingUser.specialNeeds = .breastfeeding

            // Act
            let normalRec = service.getRecommendation(for: .iron, user: normalUser)
            let breastfeedingRec = service.getRecommendation(for: .iron, user: breastfeedingUser)

            // Assert
            #expect(breastfeedingRec != nil)
            #expect(normalRec != nil)
            #expect(breastfeedingRec?.recommendedAmount ?? 0 > normalRec?.recommendedAmount ?? 0)
            #expect(breastfeedingRec?.recommendedAmount == 20.0,
                   "Breastfeeding iron recommendation should be 20 mg")
        }

        @Test("Service should return higher iodine recommendation for breastfeeding user")
        func testBreastfeedingIodineRecommendation() {
            // Arrange
            let service = RecommendationService()
            let normalUser = UserProfile(name: "Normal", userType: .female)
            let breastfeedingUser = UserProfile(name: "Breastfeeding", userType: .female)
            breastfeedingUser.specialNeeds = .breastfeeding

            // Act
            let normalRec = service.getRecommendation(for: .iodine, user: normalUser)
            let breastfeedingRec = service.getRecommendation(for: .iodine, user: breastfeedingUser)

            // Assert
            #expect(breastfeedingRec != nil)
            #expect(normalRec != nil)
            #expect(breastfeedingRec?.recommendedAmount ?? 0 > normalRec?.recommendedAmount ?? 0)
            #expect(breastfeedingRec?.recommendedAmount == 230.0,
                   "Breastfeeding iodine recommendation should be 230 μg (DGE 2025/2026 update)")
        }

        @Test("Service should return normal recommendation when specialNeeds is none")
        func testNoSpecialNeeds() {
            // Arrange
            let service = RecommendationService()
            let userWithNone = UserProfile(name: "Normal", userType: .female)
            userWithNone.specialNeeds = .none
            let userWithNil = UserProfile(name: "Nil", userType: .female)

            // Act
            let noneRec = service.getRecommendation(for: .folate, user: userWithNone)
            let nilRec = service.getRecommendation(for: .folate, user: userWithNil)

            // Assert
            #expect(noneRec?.recommendedAmount == nilRec?.recommendedAmount,
                   "None and nil special needs should return same recommendation")
            #expect(noneRec?.recommendedAmount == 300.0,
                   "Normal female folate should be 300 μg")
        }

        @Test("Service should check for special recommendation availability")
        func testHasSpecialRecommendation() {
            // Arrange
            let service = RecommendationService()

            // Act & Assert - nutrients with special recommendations
            #expect(service.hasSpecialRecommendation(for: .folate, specialNeeds: .pregnant))
            #expect(service.hasSpecialRecommendation(for: .iron, specialNeeds: .pregnant))
            #expect(service.hasSpecialRecommendation(for: .iodine, specialNeeds: .pregnant))
            #expect(service.hasSpecialRecommendation(for: .folate, specialNeeds: .breastfeeding))
            #expect(service.hasSpecialRecommendation(for: .iron, specialNeeds: .breastfeeding))
            #expect(service.hasSpecialRecommendation(for: .iodine, specialNeeds: .breastfeeding))

            // Nutrients without special recommendations should return false
            #expect(!service.hasSpecialRecommendation(for: .biotin, specialNeeds: .pregnant))
            #expect(!service.hasSpecialRecommendation(for: .chromium, specialNeeds: .breastfeeding))
        }

        @Test("Service should return all recommendations considering special needs")
        func testGetAllRecommendationsWithSpecialNeeds() {
            // Arrange
            let service = RecommendationService()
            let normalUser = UserProfile(name: "Normal", userType: .female)
            let pregnantUser = UserProfile(name: "Pregnant", userType: .female)
            pregnantUser.specialNeeds = .pregnant

            // Act
            let normalRecs = service.getAllRecommendations(for: normalUser)
            let pregnantRecs = service.getAllRecommendations(for: pregnantUser)

            // Assert
            #expect(normalRecs.count == NutrientType.allCases.count)
            #expect(pregnantRecs.count == NutrientType.allCases.count)

            // Find folate recommendations
            let normalFolate = normalRecs.first { $0.nutrientType == .folate }
            let pregnantFolate = pregnantRecs.first { $0.nutrientType == .folate }

            #expect(normalFolate?.recommendedAmount == 300.0)
            #expect(pregnantFolate?.recommendedAmount == 550.0)
        }

        // MARK: - Extended DGE Data Tests (Sprint 6 - Phase 6)

        @Test("Service should return vitamin E recommendation for pregnant user")
        func testPregnantVitaminERecommendation() {
            // Arrange
            let service = RecommendationService()
            let pregnantUser = UserProfile(name: "Pregnant", userType: .female)
            pregnantUser.specialNeeds = .pregnant

            // Act
            let pregnantRec = service.getRecommendation(for: .vitaminE, user: pregnantUser)

            // Assert
            #expect(pregnantRec != nil)
            #expect(pregnantRec?.recommendedAmount == 8.0,
                   "Pregnant vitamin E recommendation should be 8 mg (DGE 2025/2026)")
        }

        @Test("Service should return vitamin E recommendation for breastfeeding user")
        func testBreastfeedingVitaminERecommendation() {
            // Arrange
            let service = RecommendationService()
            let breastfeedingUser = UserProfile(name: "Breastfeeding", userType: .female)
            breastfeedingUser.specialNeeds = .breastfeeding

            // Act
            let breastfeedingRec = service.getRecommendation(for: .vitaminE, user: breastfeedingUser)

            // Assert
            #expect(breastfeedingRec != nil)
            #expect(breastfeedingRec?.recommendedAmount == 13.0,
                   "Breastfeeding vitamin E recommendation should be 13 mg (DGE 2025/2026)")
        }

        @Test("Service should return vitamin B6 recommendation for pregnant user")
        func testPregnantVitaminB6Recommendation() {
            // Arrange
            let service = RecommendationService()
            let normalUser = UserProfile(name: "Normal", userType: .female)
            let pregnantUser = UserProfile(name: "Pregnant", userType: .female)
            pregnantUser.specialNeeds = .pregnant

            // Act
            let normalRec = service.getRecommendation(for: .vitaminB6, user: normalUser)
            let pregnantRec = service.getRecommendation(for: .vitaminB6, user: pregnantUser)

            // Assert
            #expect(pregnantRec != nil)
            #expect(normalRec != nil)
            #expect(pregnantRec?.recommendedAmount ?? 0 > normalRec?.recommendedAmount ?? 0)
            #expect(pregnantRec?.recommendedAmount == 1.9,
                   "Pregnant vitamin B6 recommendation should be 1.9 mg")
        }

        @Test("Service should return vitamin B6 recommendation for breastfeeding user")
        func testBreastfeedingVitaminB6Recommendation() {
            // Arrange
            let service = RecommendationService()
            let normalUser = UserProfile(name: "Normal", userType: .female)
            let breastfeedingUser = UserProfile(name: "Breastfeeding", userType: .female)
            breastfeedingUser.specialNeeds = .breastfeeding

            // Act
            let normalRec = service.getRecommendation(for: .vitaminB6, user: normalUser)
            let breastfeedingRec = service.getRecommendation(for: .vitaminB6, user: breastfeedingUser)

            // Assert
            #expect(breastfeedingRec != nil)
            #expect(normalRec != nil)
            #expect(breastfeedingRec?.recommendedAmount ?? 0 > normalRec?.recommendedAmount ?? 0)
            #expect(breastfeedingRec?.recommendedAmount == 1.6,
                   "Breastfeeding vitamin B6 recommendation should be 1.6 mg")
        }

        @Test("Service should return vitamin B12 recommendation for pregnant user")
        func testPregnantVitaminB12Recommendation() {
            // Arrange
            let service = RecommendationService()
            let normalUser = UserProfile(name: "Normal", userType: .female)
            let pregnantUser = UserProfile(name: "Pregnant", userType: .female)
            pregnantUser.specialNeeds = .pregnant

            // Act
            let normalRec = service.getRecommendation(for: .vitaminB12, user: normalUser)
            let pregnantRec = service.getRecommendation(for: .vitaminB12, user: pregnantUser)

            // Assert
            #expect(pregnantRec != nil)
            #expect(normalRec != nil)
            #expect(pregnantRec?.recommendedAmount ?? 0 > normalRec?.recommendedAmount ?? 0)
            #expect(pregnantRec?.recommendedAmount == 4.5,
                   "Pregnant vitamin B12 recommendation should be 4.5 μg")
        }

        @Test("Service should return vitamin B12 recommendation for breastfeeding user")
        func testBreastfeedingVitaminB12Recommendation() {
            // Arrange
            let service = RecommendationService()
            let normalUser = UserProfile(name: "Normal", userType: .female)
            let breastfeedingUser = UserProfile(name: "Breastfeeding", userType: .female)
            breastfeedingUser.specialNeeds = .breastfeeding

            // Act
            let normalRec = service.getRecommendation(for: .vitaminB12, user: normalUser)
            let breastfeedingRec = service.getRecommendation(for: .vitaminB12, user: breastfeedingUser)

            // Assert
            #expect(breastfeedingRec != nil)
            #expect(normalRec != nil)
            #expect(breastfeedingRec?.recommendedAmount ?? 0 > normalRec?.recommendedAmount ?? 0)
            #expect(breastfeedingRec?.recommendedAmount == 5.5,
                   "Breastfeeding vitamin B12 recommendation should be 5.5 μg")
        }

        @Test("Service should return calcium recommendation for pregnant user")
        func testPregnantCalciumRecommendation() {
            // Arrange
            let service = RecommendationService()
            let pregnantUser = UserProfile(name: "Pregnant", userType: .female)
            pregnantUser.specialNeeds = .pregnant

            // Act
            let pregnantRec = service.getRecommendation(for: .calcium, user: pregnantUser)

            // Assert
            #expect(pregnantRec != nil)
            #expect(pregnantRec?.recommendedAmount == 1000.0,
                   "Pregnant calcium recommendation should be 1000 mg")
        }

        @Test("Service should return calcium recommendation for breastfeeding user")
        func testBreastfeedingCalciumRecommendation() {
            // Arrange
            let service = RecommendationService()
            let breastfeedingUser = UserProfile(name: "Breastfeeding", userType: .female)
            breastfeedingUser.specialNeeds = .breastfeeding

            // Act
            let breastfeedingRec = service.getRecommendation(for: .calcium, user: breastfeedingUser)

            // Assert
            #expect(breastfeedingRec != nil)
            #expect(breastfeedingRec?.recommendedAmount == 1000.0,
                   "Breastfeeding calcium recommendation should be 1000 mg")
        }

        @Test("Service should return magnesium recommendation for pregnant user")
        func testPregnantMagnesiumRecommendation() {
            // Arrange
            let service = RecommendationService()
            let pregnantUser = UserProfile(name: "Pregnant", userType: .female)
            pregnantUser.specialNeeds = .pregnant

            // Act
            let pregnantRec = service.getRecommendation(for: .magnesium, user: pregnantUser)

            // Assert
            #expect(pregnantRec != nil)
            #expect(pregnantRec?.recommendedAmount == 310.0,
                   "Pregnant magnesium recommendation should be 310 mg")
        }

        @Test("Service should return magnesium recommendation for breastfeeding user")
        func testBreastfeedingMagnesiumRecommendation() {
            // Arrange
            let service = RecommendationService()
            let breastfeedingUser = UserProfile(name: "Breastfeeding", userType: .female)
            breastfeedingUser.specialNeeds = .breastfeeding

            // Act
            let breastfeedingRec = service.getRecommendation(for: .magnesium, user: breastfeedingUser)

            // Assert
            #expect(breastfeedingRec != nil)
            #expect(breastfeedingRec?.recommendedAmount == 390.0,
                   "Breastfeeding magnesium recommendation should be 390 mg")
        }

        @Test("Service should return zinc recommendation for pregnant user")
        func testPregnantZincRecommendation() {
            // Arrange
            let service = RecommendationService()
            let normalUser = UserProfile(name: "Normal", userType: .female)
            let pregnantUser = UserProfile(name: "Pregnant", userType: .female)
            pregnantUser.specialNeeds = .pregnant

            // Act
            let normalRec = service.getRecommendation(for: .zinc, user: normalUser)
            let pregnantRec = service.getRecommendation(for: .zinc, user: pregnantUser)

            // Assert
            #expect(pregnantRec != nil)
            #expect(normalRec != nil)
            #expect(pregnantRec?.recommendedAmount ?? 0 > normalRec?.recommendedAmount ?? 0)
            #expect(pregnantRec?.recommendedAmount == 11.0,
                   "Pregnant zinc recommendation should be 11 mg")
        }

        @Test("Service should return zinc recommendation for breastfeeding user")
        func testBreastfeedingZincRecommendation() {
            // Arrange
            let service = RecommendationService()
            let normalUser = UserProfile(name: "Normal", userType: .female)
            let breastfeedingUser = UserProfile(name: "Breastfeeding", userType: .female)
            breastfeedingUser.specialNeeds = .breastfeeding

            // Act
            let normalRec = service.getRecommendation(for: .zinc, user: normalUser)
            let breastfeedingRec = service.getRecommendation(for: .zinc, user: breastfeedingUser)

            // Assert
            #expect(breastfeedingRec != nil)
            #expect(normalRec != nil)
            #expect(breastfeedingRec?.recommendedAmount ?? 0 > normalRec?.recommendedAmount ?? 0)
            #expect(breastfeedingRec?.recommendedAmount == 13.0,
                   "Breastfeeding zinc recommendation should be 13 mg")
        }
    }
}
