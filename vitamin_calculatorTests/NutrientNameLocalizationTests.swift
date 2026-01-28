//
//  NutrientNameLocalizationTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 28.01.26.
//

import Testing
import Foundation
@testable import vitamin_calculator

@Suite("Nutrient Name Localization Tests")
struct NutrientNameLocalizationTests {

    // MARK: - Vitamin Localization Tests

    @Test("Vitamin A is localized correctly in all languages")
    func testVitaminALocalization() {
        let germanBundle = getBundle(for: "de")
        let englishBundle = getBundle(for: "en")
        let chineseBundle = getBundle(for: "zh-Hans")

        #expect(NSLocalizedString("nutrient_vitaminA", bundle: germanBundle, comment: "") == "Vitamin A")
        #expect(NSLocalizedString("nutrient_vitaminA", bundle: englishBundle, comment: "") == "Vitamin A")
        #expect(NSLocalizedString("nutrient_vitaminA", bundle: chineseBundle, comment: "") == "维生素A")
    }

    @Test("Vitamin D is localized correctly in all languages")
    func testVitaminDLocalization() {
        let germanBundle = getBundle(for: "de")
        let englishBundle = getBundle(for: "en")
        let chineseBundle = getBundle(for: "zh-Hans")

        #expect(NSLocalizedString("nutrient_vitaminD", bundle: germanBundle, comment: "") == "Vitamin D")
        #expect(NSLocalizedString("nutrient_vitaminD", bundle: englishBundle, comment: "") == "Vitamin D")
        #expect(NSLocalizedString("nutrient_vitaminD", bundle: chineseBundle, comment: "") == "维生素D")
    }

    @Test("Vitamin C is localized correctly in all languages")
    func testVitaminCLocalization() {
        let germanBundle = getBundle(for: "de")
        let englishBundle = getBundle(for: "en")
        let chineseBundle = getBundle(for: "zh-Hans")

        #expect(NSLocalizedString("nutrient_vitaminC", bundle: germanBundle, comment: "") == "Vitamin C")
        #expect(NSLocalizedString("nutrient_vitaminC", bundle: englishBundle, comment: "") == "Vitamin C")
        #expect(NSLocalizedString("nutrient_vitaminC", bundle: chineseBundle, comment: "") == "维生素C")
    }

    @Test("B-Complex vitamins are localized correctly")
    func testBComplexVitaminsLocalization() {
        let germanBundle = getBundle(for: "de")
        let englishBundle = getBundle(for: "en")
        let chineseBundle = getBundle(for: "zh-Hans")

        // Vitamin B1
        #expect(NSLocalizedString("nutrient_vitaminB1", bundle: germanBundle, comment: "") == "Vitamin B1 (Thiamin)")
        #expect(NSLocalizedString("nutrient_vitaminB1", bundle: englishBundle, comment: "") == "Vitamin B1 (Thiamin)")
        #expect(NSLocalizedString("nutrient_vitaminB1", bundle: chineseBundle, comment: "") == "维生素B1 (硫胺素)")

        // Vitamin B2
        #expect(NSLocalizedString("nutrient_vitaminB2", bundle: germanBundle, comment: "") == "Vitamin B2 (Riboflavin)")
        #expect(NSLocalizedString("nutrient_vitaminB2", bundle: englishBundle, comment: "") == "Vitamin B2 (Riboflavin)")
        #expect(NSLocalizedString("nutrient_vitaminB2", bundle: chineseBundle, comment: "") == "维生素B2 (核黄素)")

        // Vitamin B3
        #expect(NSLocalizedString("nutrient_vitaminB3", bundle: germanBundle, comment: "") == "Vitamin B3 (Niacin)")
        #expect(NSLocalizedString("nutrient_vitaminB3", bundle: englishBundle, comment: "") == "Vitamin B3 (Niacin)")
        #expect(NSLocalizedString("nutrient_vitaminB3", bundle: chineseBundle, comment: "") == "维生素B3 (烟酸)")

        // Vitamin B6
        #expect(NSLocalizedString("nutrient_vitaminB6", bundle: germanBundle, comment: "") == "Vitamin B6 (Pyridoxin)")
        #expect(NSLocalizedString("nutrient_vitaminB6", bundle: englishBundle, comment: "") == "Vitamin B6 (Pyridoxine)")
        #expect(NSLocalizedString("nutrient_vitaminB6", bundle: chineseBundle, comment: "") == "维生素B6 (吡哆醇)")

        // Vitamin B12
        #expect(NSLocalizedString("nutrient_vitaminB12", bundle: germanBundle, comment: "") == "Vitamin B12 (Cobalamin)")
        #expect(NSLocalizedString("nutrient_vitaminB12", bundle: englishBundle, comment: "") == "Vitamin B12 (Cobalamin)")
        #expect(NSLocalizedString("nutrient_vitaminB12", bundle: chineseBundle, comment: "") == "维生素B12 (钴胺素)")
    }

    @Test("Other vitamins are localized correctly")
    func testOtherVitaminsLocalization() {
        let germanBundle = getBundle(for: "de")
        let englishBundle = getBundle(for: "en")
        let chineseBundle = getBundle(for: "zh-Hans")

        // Vitamin E
        #expect(NSLocalizedString("nutrient_vitaminE", bundle: germanBundle, comment: "") == "Vitamin E")
        #expect(NSLocalizedString("nutrient_vitaminE", bundle: englishBundle, comment: "") == "Vitamin E")
        #expect(NSLocalizedString("nutrient_vitaminE", bundle: chineseBundle, comment: "") == "维生素E")

        // Vitamin K
        #expect(NSLocalizedString("nutrient_vitaminK", bundle: germanBundle, comment: "") == "Vitamin K")
        #expect(NSLocalizedString("nutrient_vitaminK", bundle: englishBundle, comment: "") == "Vitamin K")
        #expect(NSLocalizedString("nutrient_vitaminK", bundle: chineseBundle, comment: "") == "维生素K")

        // Folate
        #expect(NSLocalizedString("nutrient_folate", bundle: germanBundle, comment: "") == "Folsäure")
        #expect(NSLocalizedString("nutrient_folate", bundle: englishBundle, comment: "") == "Folate")
        #expect(NSLocalizedString("nutrient_folate", bundle: chineseBundle, comment: "") == "叶酸")

        // Biotin
        #expect(NSLocalizedString("nutrient_biotin", bundle: germanBundle, comment: "") == "Biotin")
        #expect(NSLocalizedString("nutrient_biotin", bundle: englishBundle, comment: "") == "Biotin")
        #expect(NSLocalizedString("nutrient_biotin", bundle: chineseBundle, comment: "") == "生物素")

        // Pantothenic Acid
        #expect(NSLocalizedString("nutrient_pantothenicAcid", bundle: germanBundle, comment: "") == "Pantothensäure")
        #expect(NSLocalizedString("nutrient_pantothenicAcid", bundle: englishBundle, comment: "") == "Pantothenic Acid")
        #expect(NSLocalizedString("nutrient_pantothenicAcid", bundle: chineseBundle, comment: "") == "泛酸")
    }

    // MARK: - Mineral Localization Tests

    @Test("Major minerals are localized correctly")
    func testMajorMineralsLocalization() {
        let germanBundle = getBundle(for: "de")
        let englishBundle = getBundle(for: "en")
        let chineseBundle = getBundle(for: "zh-Hans")

        // Calcium
        #expect(NSLocalizedString("nutrient_calcium", bundle: germanBundle, comment: "") == "Calcium")
        #expect(NSLocalizedString("nutrient_calcium", bundle: englishBundle, comment: "") == "Calcium")
        #expect(NSLocalizedString("nutrient_calcium", bundle: chineseBundle, comment: "") == "钙")

        // Magnesium
        #expect(NSLocalizedString("nutrient_magnesium", bundle: germanBundle, comment: "") == "Magnesium")
        #expect(NSLocalizedString("nutrient_magnesium", bundle: englishBundle, comment: "") == "Magnesium")
        #expect(NSLocalizedString("nutrient_magnesium", bundle: chineseBundle, comment: "") == "镁")

        // Iron
        #expect(NSLocalizedString("nutrient_iron", bundle: germanBundle, comment: "") == "Eisen")
        #expect(NSLocalizedString("nutrient_iron", bundle: englishBundle, comment: "") == "Iron")
        #expect(NSLocalizedString("nutrient_iron", bundle: chineseBundle, comment: "") == "铁")

        // Zinc
        #expect(NSLocalizedString("nutrient_zinc", bundle: germanBundle, comment: "") == "Zink")
        #expect(NSLocalizedString("nutrient_zinc", bundle: englishBundle, comment: "") == "Zinc")
        #expect(NSLocalizedString("nutrient_zinc", bundle: chineseBundle, comment: "") == "锌")
    }

    @Test("Trace minerals are localized correctly")
    func testTraceMineralsLocalization() {
        let germanBundle = getBundle(for: "de")
        let englishBundle = getBundle(for: "en")
        let chineseBundle = getBundle(for: "zh-Hans")

        // Selenium
        #expect(NSLocalizedString("nutrient_selenium", bundle: germanBundle, comment: "") == "Selen")
        #expect(NSLocalizedString("nutrient_selenium", bundle: englishBundle, comment: "") == "Selenium")
        #expect(NSLocalizedString("nutrient_selenium", bundle: chineseBundle, comment: "") == "硒")

        // Iodine
        #expect(NSLocalizedString("nutrient_iodine", bundle: germanBundle, comment: "") == "Jod")
        #expect(NSLocalizedString("nutrient_iodine", bundle: englishBundle, comment: "") == "Iodine")
        #expect(NSLocalizedString("nutrient_iodine", bundle: chineseBundle, comment: "") == "碘")

        // Copper
        #expect(NSLocalizedString("nutrient_copper", bundle: germanBundle, comment: "") == "Kupfer")
        #expect(NSLocalizedString("nutrient_copper", bundle: englishBundle, comment: "") == "Copper")
        #expect(NSLocalizedString("nutrient_copper", bundle: chineseBundle, comment: "") == "铜")

        // Manganese
        #expect(NSLocalizedString("nutrient_manganese", bundle: germanBundle, comment: "") == "Mangan")
        #expect(NSLocalizedString("nutrient_manganese", bundle: englishBundle, comment: "") == "Manganese")
        #expect(NSLocalizedString("nutrient_manganese", bundle: chineseBundle, comment: "") == "锰")

        // Chromium
        #expect(NSLocalizedString("nutrient_chromium", bundle: germanBundle, comment: "") == "Chrom")
        #expect(NSLocalizedString("nutrient_chromium", bundle: englishBundle, comment: "") == "Chromium")
        #expect(NSLocalizedString("nutrient_chromium", bundle: chineseBundle, comment: "") == "铬")

        // Molybdenum
        #expect(NSLocalizedString("nutrient_molybdenum", bundle: germanBundle, comment: "") == "Molybdän")
        #expect(NSLocalizedString("nutrient_molybdenum", bundle: englishBundle, comment: "") == "Molybdenum")
        #expect(NSLocalizedString("nutrient_molybdenum", bundle: chineseBundle, comment: "") == "钼")
    }

    // MARK: - NutrientType Integration Test

    @Test("NutrientType localizedName uses correct localization")
    func testNutrientTypeLocalizedName() {
        // Test a few nutrients to ensure they're using the localization system
        let vitaminA = NutrientType.vitaminA
        let localizedName = vitaminA.localizedName

        // Should return a localized value, not empty
        #expect(!localizedName.isEmpty)

        // For vitamins A-E, name should contain "Vitamin" in English or German, or "维生素" in Chinese
        #expect(localizedName.contains("Vitamin") || localizedName.contains("维生素"))
    }

    // MARK: - Helper Methods

    private func getBundle(for languageId: String) -> Bundle {
        guard let path = Bundle.main.path(forResource: languageId, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }
}
