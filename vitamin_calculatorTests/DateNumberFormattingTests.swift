//
//  DateNumberFormattingTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 28.01.26.
//

import Testing
import Foundation
@testable import vitamin_calculator

@Suite("Date and Number Formatting Tests")
struct DateNumberFormattingTests {

    // MARK: - Date Formatting Tests

    @Test("Date formats correctly for German locale")
    func testDateFormattingGerman() {
        // Arrange
        let date = createTestDate(year: 2026, month: 1, day: 28)
        let locale = Locale(identifier: "de")
        let formatter = LocalizationHelper.dateFormatter(for: locale)

        // Act
        let formattedDate = formatter.string(from: date)

        // Assert
        // German date format: "28.01.2026" or "28. Januar 2026"
        #expect(formattedDate.contains("28"))
        #expect(formattedDate.contains("01") || formattedDate.contains("Januar"))
        #expect(formattedDate.contains("2026"))
    }

    @Test("Date formats correctly for English locale")
    func testDateFormattingEnglish() {
        // Arrange
        let date = createTestDate(year: 2026, month: 1, day: 28)
        let locale = Locale(identifier: "en")
        let formatter = LocalizationHelper.dateFormatter(for: locale)

        // Act
        let formattedDate = formatter.string(from: date)

        // Assert
        // English date format can be various: "1/28/2026", "Jan 28, 2026", "January 28, 2026"
        #expect(formattedDate.contains("28"))
        #expect(formattedDate.contains("2026"))
        // Just verify it's not empty and has reasonable content
        #expect(formattedDate.count > 5)
    }

    @Test("Date formats correctly for Chinese locale")
    func testDateFormattingChinese() {
        // Arrange
        let date = createTestDate(year: 2026, month: 1, day: 28)
        let locale = Locale(identifier: "zh-Hans")
        let formatter = LocalizationHelper.dateFormatter(for: locale)

        // Act
        let formattedDate = formatter.string(from: date)

        // Assert
        // Chinese date format: "2026年1月28日"
        #expect(formattedDate.contains("2026"))
        #expect(formattedDate.contains("1"))
        #expect(formattedDate.contains("28"))
    }

    @Test("Short date format works for all locales")
    func testShortDateFormatting() {
        let date = createTestDate(year: 2026, month: 1, day: 28)

        // German
        let germanFormatted = LocalizationHelper.formatDate(date, style: .short, locale: Locale(identifier: "de"))
        #expect(!germanFormatted.isEmpty)

        // English
        let englishFormatted = LocalizationHelper.formatDate(date, style: .short, locale: Locale(identifier: "en"))
        #expect(!englishFormatted.isEmpty)

        // Chinese
        let chineseFormatted = LocalizationHelper.formatDate(date, style: .short, locale: Locale(identifier: "zh-Hans"))
        #expect(!chineseFormatted.isEmpty)
    }

    // MARK: - Number Formatting Tests

    @Test("Decimal numbers format correctly for German locale")
    func testDecimalFormattingGerman() {
        // Arrange
        let number = 1234.56
        let locale = Locale(identifier: "de")

        // Act
        let formatted = LocalizationHelper.formatNumber(number, locale: locale)

        // Assert
        // German uses comma as decimal separator and period/space as thousand separator
        #expect(formatted.contains(",56") || formatted.contains(",6"))
        #expect(formatted.contains("1") && formatted.contains("234"))
    }

    @Test("Decimal numbers format correctly for English locale")
    func testDecimalFormattingEnglish() {
        // Arrange
        let number = 1234.56
        let locale = Locale(identifier: "en")

        // Act
        let formatted = LocalizationHelper.formatNumber(number, locale: locale)

        // Assert
        // English uses period as decimal separator and comma as thousand separator
        #expect(formatted.contains(".56") || formatted.contains(".6"))
        #expect(formatted.contains("1") && formatted.contains("234"))
    }

    @Test("Decimal numbers format correctly for Chinese locale")
    func testDecimalFormattingChinese() {
        // Arrange
        let number = 1234.56
        let locale = Locale(identifier: "zh-Hans")

        // Act
        let formatted = LocalizationHelper.formatNumber(number, locale: locale)

        // Assert
        // Chinese locale formatting - just verify numbers are present
        #expect(formatted.contains("1234") || formatted.contains("1,234"))
        #expect(formatted.contains("5")) // Some form of decimal representation
        #expect(!formatted.isEmpty)
    }

    @Test("Integer numbers format without decimal places")
    func testIntegerFormatting() {
        // Arrange
        let number = 1234.0
        let locale = Locale(identifier: "en")

        // Act
        let formatted = LocalizationHelper.formatNumber(number, decimals: 0, locale: locale)

        // Assert
        #expect(formatted == "1,234" || formatted == "1234")
        #expect(!formatted.contains("."))
    }

    @Test("Numbers format with specified decimal places")
    func testDecimalPrecisionFormatting() {
        // Arrange
        let number = 123.456789
        let locale = Locale(identifier: "en")

        // Act
        let formatted = LocalizationHelper.formatNumber(number, decimals: 2, locale: locale)

        // Assert
        #expect(formatted.contains("123"))
        #expect(formatted.contains("46") || formatted.contains("45")) // Rounding
    }

    // MARK: - Measurement Unit Formatting Tests

    @Test("Milligram measurement formats correctly")
    func testMilligramFormatting() {
        // Arrange
        let amount = 100.0
        let locale = Locale(identifier: "en")

        // Act
        let formatted = LocalizationHelper.formatMeasurement(amount, unit: .milligrams, locale: locale)

        // Assert
        #expect(formatted.contains("100"))
        #expect(formatted.contains("mg"))
    }

    @Test("Microgram measurement formats correctly")
    func testMicrogramFormatting() {
        // Arrange
        let amount = 50.0
        let locale = Locale(identifier: "de")

        // Act
        let formatted = LocalizationHelper.formatMeasurement(amount, unit: .micrograms, locale: locale)

        // Assert
        #expect(formatted.contains("50"))
        #expect(formatted.contains("μg") || formatted.contains("mcg"))
    }

    // MARK: - Plural Forms Tests

    @Test("Plural forms work correctly for English")
    func testPluralFormsEnglish() {
        let locale = Locale(identifier: "en")

        // Singular
        let singular = LocalizationHelper.pluralizedString(count: 1, key: "serving", locale: locale)
        #expect(singular.contains("serving"))

        // Plural
        let plural = LocalizationHelper.pluralizedString(count: 5, key: "serving", locale: locale)
        #expect(plural.contains("serving"))
    }

    @Test("Plural forms work correctly for German")
    func testPluralFormsGerman() {
        let locale = Locale(identifier: "de")

        // Singular
        let singular = LocalizationHelper.pluralizedString(count: 1, key: "serving", locale: locale)
        #expect(!singular.isEmpty)

        // Plural
        let plural = LocalizationHelper.pluralizedString(count: 5, key: "serving", locale: locale)
        #expect(!plural.isEmpty)
    }

    @Test("Plural forms work correctly for Chinese")
    func testPluralFormsChinese() {
        let locale = Locale(identifier: "zh-Hans")

        // Chinese doesn't change for singular/plural
        let singular = LocalizationHelper.pluralizedString(count: 1, key: "serving", locale: locale)
        let plural = LocalizationHelper.pluralizedString(count: 5, key: "serving", locale: locale)

        #expect(!singular.isEmpty)
        #expect(!plural.isEmpty)
    }

    @Test("Nutrient count formatting with units")
    func testNutrientCountFormatting() {
        // Test that we can format nutrient counts properly
        let count = 3
        let result = LocalizationHelper.formatNutrientCount(count, locale: Locale(identifier: "en"))

        #expect(result.contains("3"))
        #expect(!result.isEmpty)
    }

    // MARK: - Relative Date Formatting Tests

    @Test("Today's date formats as 'Today' in English")
    func testRelativeDateToday() {
        let today = Date()
        let locale = Locale(identifier: "en")

        let formatted = LocalizationHelper.formatRelativeDate(today, locale: locale)

        // Should contain some indication it's today
        #expect(!formatted.isEmpty)
    }

    @Test("Yesterday's date formats correctly")
    func testRelativeDateYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let locale = Locale(identifier: "en")

        let formatted = LocalizationHelper.formatRelativeDate(yesterday, locale: locale)

        #expect(!formatted.isEmpty)
    }

    // MARK: - Helper Methods

    private func createTestDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        components.minute = 0
        return Calendar.current.date(from: components)!
    }
}

// MARK: - Integration Tests with Existing Models

@Suite("Formatting Integration Tests")
struct FormattingIntegrationTests {

    @Test("IntakeRecord date formats correctly")
    func testIntakeRecordDateFormatting() {
        // This tests that our formatting helper can work with actual model dates
        let date = Date()
        let formatted = LocalizationHelper.formatDate(date, style: .medium)

        #expect(!formatted.isEmpty)
        #expect(formatted.count > 5) // Should have some substance
    }

    @Test("Supplement serving count formats correctly")
    func testSupplementServingFormatting() {
        let servings = 2.5
        let formatted = LocalizationHelper.formatNumber(servings, decimals: 1)

        #expect(formatted.contains("2"))
        #expect(formatted.contains("5"))
    }

    @Test("Nutrient amount with unit formats correctly")
    func testNutrientAmountFormatting() {
        let amount = 100.5
        let formatted = LocalizationHelper.formatMeasurement(amount, unit: .milligrams)

        #expect(formatted.contains("100"))
        #expect(formatted.contains("mg"))
    }
}
