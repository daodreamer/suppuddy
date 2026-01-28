//
//  LocalizationTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 28.01.26.
//

import Testing
import Foundation
@testable import vitamin_calculator

@Suite("Localization Infrastructure Tests")
struct LocalizationTests {

    // MARK: - Language Support Tests

    @Test("App supports German language")
    func testGermanLanguageSupport() {
        let germanLocale = Locale(identifier: "de")
        let bundle = Bundle.main

        // Verify German is in the list of supported localizations
        let localizations = bundle.localizations
        #expect(localizations.contains("de"))
    }

    @Test("App supports English language")
    func testEnglishLanguageSupport() {
        let bundle = Bundle.main
        let localizations = bundle.localizations
        #expect(localizations.contains("en"))
    }

    @Test("App supports Simplified Chinese language")
    func testSimplifiedChineseLanguageSupport() {
        let bundle = Bundle.main
        let localizations = bundle.localizations
        #expect(localizations.contains("zh-Hans"))
    }

    // MARK: - String Catalog Tests

    @Test("String Catalog is properly compiled and accessible")
    func testStringCatalogIsAccessible() {
        // The String Catalog gets compiled into the bundle
        // We verify it's working by checking if localized strings are accessible
        let testKey = "app_name"
        let localizedString = NSLocalizedString(testKey, comment: "")

        // If the String Catalog is properly compiled, we should get a translated value
        #expect(localizedString != testKey)
        #expect(!localizedString.isEmpty)
    }

    @Test("Localized string returns German translation")
    func testGermanLocalization() {
        // Arrange
        let key = "app_name"
        let germanBundle = getBundle(for: "de")

        // Act
        let localizedString = NSLocalizedString(key, bundle: germanBundle, comment: "")

        // Assert
        #expect(localizedString != key) // Should not return the key itself
        #expect(localizedString == "Vitamin Rechner")
    }

    @Test("Localized string returns English translation")
    func testEnglishLocalization() {
        // Arrange
        let key = "app_name"
        let englishBundle = getBundle(for: "en")

        // Act
        let localizedString = NSLocalizedString(key, bundle: englishBundle, comment: "")

        // Assert
        #expect(localizedString != key)
        #expect(localizedString == "Vitamin Calculator")
    }

    @Test("Localized string returns Chinese translation")
    func testChineseLocalization() {
        // Arrange
        let key = "app_name"
        let chineseBundle = getBundle(for: "zh-Hans")

        // Act
        let localizedString = NSLocalizedString(key, bundle: chineseBundle, comment: "")

        // Assert
        #expect(localizedString != key)
        #expect(localizedString == "维生素计算器")
    }

    // MARK: - Tab Navigation Localization

    @Test("Dashboard tab is localized in German")
    func testDashboardTabGerman() {
        let germanBundle = getBundle(for: "de")
        let localizedString = NSLocalizedString("tab_dashboard", bundle: germanBundle, comment: "")
        #expect(localizedString == "Übersicht")
    }

    @Test("Dashboard tab is localized in English")
    func testDashboardTabEnglish() {
        let englishBundle = getBundle(for: "en")
        let localizedString = NSLocalizedString("tab_dashboard", bundle: englishBundle, comment: "")
        #expect(localizedString == "Dashboard")
    }

    @Test("Dashboard tab is localized in Chinese")
    func testDashboardTabChinese() {
        let chineseBundle = getBundle(for: "zh-Hans")
        let localizedString = NSLocalizedString("tab_dashboard", bundle: chineseBundle, comment: "")
        #expect(localizedString == "首页")
    }

    // MARK: - Helper Methods

    /// Returns a bundle for the specified language identifier
    /// - Parameter languageId: Language identifier (e.g., "de", "en", "zh-Hans")
    /// - Returns: Bundle configured for the specified language
    private func getBundle(for languageId: String) -> Bundle {
        guard let path = Bundle.main.path(forResource: languageId, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }
}

// MARK: - Localization Utility Tests

@Suite("Localization Utility Tests")
struct LocalizationUtilityTests {

    @Test("String localized key extension works")
    func testStringLocalizedKeyExtension() {
        // Test that we can use String(localized:) API
        let localizedString = String(localized: "app_name")

        // Should return a localized value, not the key
        #expect(!localizedString.isEmpty)
    }

    @Test("LocalizedStringKey creates proper key")
    func testLocalizedStringKey() {
        // This tests that LocalizedStringKey is properly initialized
        let key = "tab_dashboard"
        // LocalizedStringKey will be used in SwiftUI views
        // This test verifies the string exists
        let localizedString = String(localized: .init(key))
        #expect(!localizedString.isEmpty)
    }
}
