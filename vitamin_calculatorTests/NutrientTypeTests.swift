//
//  NutrientTypeTests.swift
//  vitamin_calculatorTests
//
//  Created by Jiongdao Wang on 25.01.26.
//

import Testing
@testable import vitamin_calculator

@Suite("NutrientType Model Tests")
struct NutrientTypeTests {

    @Suite("Vitamin Cases Tests")
    struct VitaminTests {
        @Test("NutrientType should have vitamin A")
        func testHasVitaminA() {
            let vitaminA = NutrientType.vitaminA
            #expect(vitaminA != nil)
        }

        @Test("NutrientType should have vitamin D")
        func testHasVitaminD() {
            let vitaminD = NutrientType.vitaminD
            #expect(vitaminD != nil)
        }

        @Test("NutrientType should have vitamin E")
        func testHasVitaminE() {
            let vitaminE = NutrientType.vitaminE
            #expect(vitaminE != nil)
        }

        @Test("NutrientType should have vitamin K")
        func testHasVitaminK() {
            let vitaminK = NutrientType.vitaminK
            #expect(vitaminK != nil)
        }

        @Test("NutrientType should have vitamin C")
        func testHasVitaminC() {
            let vitaminC = NutrientType.vitaminC
            #expect(vitaminC != nil)
        }

        @Test("NutrientType should have vitamin B1 (Thiamin)")
        func testHasVitaminB1() {
            let vitaminB1 = NutrientType.vitaminB1
            #expect(vitaminB1 != nil)
        }

        @Test("NutrientType should have vitamin B2 (Riboflavin)")
        func testHasVitaminB2() {
            let vitaminB2 = NutrientType.vitaminB2
            #expect(vitaminB2 != nil)
        }

        @Test("NutrientType should have vitamin B3 (Niacin)")
        func testHasVitaminB3() {
            let vitaminB3 = NutrientType.vitaminB3
            #expect(vitaminB3 != nil)
        }

        @Test("NutrientType should have vitamin B6 (Pyridoxin)")
        func testHasVitaminB6() {
            let vitaminB6 = NutrientType.vitaminB6
            #expect(vitaminB6 != nil)
        }

        @Test("NutrientType should have vitamin B12 (Cobalamin)")
        func testHasVitaminB12() {
            let vitaminB12 = NutrientType.vitaminB12
            #expect(vitaminB12 != nil)
        }

        @Test("NutrientType should have folate")
        func testHasFolate() {
            let folate = NutrientType.folate
            #expect(folate != nil)
        }

        @Test("NutrientType should have biotin")
        func testHasBiotin() {
            let biotin = NutrientType.biotin
            #expect(biotin != nil)
        }

        @Test("NutrientType should have pantothenic acid")
        func testHasPantothenicAcid() {
            let pantothenicAcid = NutrientType.pantothenicAcid
            #expect(pantothenicAcid != nil)
        }
    }

    @Suite("Mineral Cases Tests")
    struct MineralTests {
        @Test("NutrientType should have calcium")
        func testHasCalcium() {
            let calcium = NutrientType.calcium
            #expect(calcium != nil)
        }

        @Test("NutrientType should have magnesium")
        func testHasMagnesium() {
            let magnesium = NutrientType.magnesium
            #expect(magnesium != nil)
        }

        @Test("NutrientType should have iron")
        func testHasIron() {
            let iron = NutrientType.iron
            #expect(iron != nil)
        }

        @Test("NutrientType should have zinc")
        func testHasZinc() {
            let zinc = NutrientType.zinc
            #expect(zinc != nil)
        }

        @Test("NutrientType should have selenium")
        func testHasSelenium() {
            let selenium = NutrientType.selenium
            #expect(selenium != nil)
        }

        @Test("NutrientType should have iodine")
        func testHasIodine() {
            let iodine = NutrientType.iodine
            #expect(iodine != nil)
        }

        @Test("NutrientType should have copper")
        func testHasCopper() {
            let copper = NutrientType.copper
            #expect(copper != nil)
        }

        @Test("NutrientType should have manganese")
        func testHasManganese() {
            let manganese = NutrientType.manganese
            #expect(manganese != nil)
        }

        @Test("NutrientType should have chromium")
        func testHasChromium() {
            let chromium = NutrientType.chromium
            #expect(chromium != nil)
        }

        @Test("NutrientType should have molybdenum")
        func testHasMolybdenum() {
            let molybdenum = NutrientType.molybdenum
            #expect(molybdenum != nil)
        }
    }

    @Suite("Localized Name Tests")
    struct LocalizedNameTests {
        @Test("Vitamin C should provide non-empty localized name")
        func testVitaminCLocalizedName() {
            let vitaminC = NutrientType.vitaminC
            #expect(!vitaminC.localizedName.isEmpty)
        }

        @Test("Calcium should provide non-empty localized name")
        func testCalciumLocalizedName() {
            let calcium = NutrientType.calcium
            #expect(!calcium.localizedName.isEmpty)
        }

        @Test("All nutrient types should have localized names")
        func testAllNutrientsHaveLocalizedNames() {
            for nutrient in NutrientType.allCases {
                #expect(!nutrient.localizedName.isEmpty,
                       "NutrientType.\(nutrient) should have a localized name")
            }
        }
    }

    @Suite("Unit Tests")
    struct UnitTests {
        @Test("Vitamin C should have correct unit")
        func testVitaminCUnit() {
            let vitaminC = NutrientType.vitaminC
            #expect(vitaminC.unit == "mg")
        }

        @Test("Vitamin D should use micrograms")
        func testVitaminDUnit() {
            let vitaminD = NutrientType.vitaminD
            #expect(vitaminD.unit == "μg")
        }

        @Test("Calcium should use milligrams")
        func testCalciumUnit() {
            let calcium = NutrientType.calcium
            #expect(calcium.unit == "mg")
        }

        @Test("All nutrient types should have units")
        func testAllNutrientsHaveUnits() {
            for nutrient in NutrientType.allCases {
                #expect(!nutrient.unit.isEmpty,
                       "NutrientType.\(nutrient) should have a unit")
            }
        }
    }

    @Suite("CaseIterable Tests")
    struct CaseIterableTests {
        @Test("NutrientType should have all 23 cases")
        func testAllCasesCount() {
            // 13 vitamins + 10 minerals = 23 total
            #expect(NutrientType.allCases.count == 23)
        }

        @Test("allCases should contain vitamin A")
        func testAllCasesContainsVitaminA() {
            #expect(NutrientType.allCases.contains(.vitaminA))
        }

        @Test("allCases should contain calcium")
        func testAllCasesContainsCalcium() {
            #expect(NutrientType.allCases.contains(.calcium))
        }
    }
}
