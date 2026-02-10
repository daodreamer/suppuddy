//
//  AccessibilityHelperLocalizationTests.swift
//  vitamin_calculatorTests
//
//  TDD: Verify AccessibilityHelper uses localized strings
//

import Testing
import Foundation
@testable import vitamin_calculator

@Suite("AccessibilityHelper Localization Tests")
struct AccessibilityHelperLocalizationTests {

    // MARK: - Tab Bar Labels

    @Test("Tab labels are non-empty localized strings")
    func testTabLabelsAreLocalized() {
        #expect(!AccessibilityHelper.tabDashboard.isEmpty)
        #expect(!AccessibilityHelper.tabRecord.isEmpty)
        #expect(!AccessibilityHelper.tabSupplements.isEmpty)
        #expect(!AccessibilityHelper.tabHistory.isEmpty)
        #expect(!AccessibilityHelper.tabProfile.isEmpty)
    }

    @Test("Tab hints are non-empty localized strings")
    func testTabHintsAreLocalized() {
        #expect(!AccessibilityHelper.tabDashboardHint.isEmpty)
        #expect(!AccessibilityHelper.tabRecordHint.isEmpty)
        #expect(!AccessibilityHelper.tabSupplementsHint.isEmpty)
        #expect(!AccessibilityHelper.tabHistoryHint.isEmpty)
        #expect(!AccessibilityHelper.tabProfileHint.isEmpty)
    }

    // MARK: - Button Labels

    @Test("Button labels are non-empty localized strings")
    func testButtonLabelsAreLocalized() {
        #expect(!AccessibilityHelper.addButton.isEmpty)
        #expect(!AccessibilityHelper.editButton.isEmpty)
        #expect(!AccessibilityHelper.deleteButton.isEmpty)
        #expect(!AccessibilityHelper.saveButton.isEmpty)
        #expect(!AccessibilityHelper.cancelButton.isEmpty)
        #expect(!AccessibilityHelper.closeButton.isEmpty)
        #expect(!AccessibilityHelper.doneButton.isEmpty)
        #expect(!AccessibilityHelper.nextButton.isEmpty)
        #expect(!AccessibilityHelper.previousButton.isEmpty)
        #expect(!AccessibilityHelper.retryButton.isEmpty)
    }

    // MARK: - Supplement Actions

    @Test("Supplement action labels are non-empty localized strings")
    func testSupplementActionsAreLocalized() {
        #expect(!AccessibilityHelper.supplementAddButton.isEmpty)
        #expect(!AccessibilityHelper.supplementSortButton.isEmpty)
        #expect(!AccessibilityHelper.supplementDeleteAction.isEmpty)
        #expect(!AccessibilityHelper.supplementEditAction.isEmpty)
        #expect(!AccessibilityHelper.supplementActivateAction.isEmpty)
        #expect(!AccessibilityHelper.supplementDeactivateAction.isEmpty)
    }

    // MARK: - Status Labels

    @Test("Status labels are non-empty localized strings")
    func testStatusLabelsAreLocalized() {
        #expect(!AccessibilityHelper.loadingStatus.isEmpty)
        #expect(!AccessibilityHelper.refreshingStatus.isEmpty)
        #expect(!AccessibilityHelper.savingStatus.isEmpty)
        #expect(!AccessibilityHelper.deletingStatus.isEmpty)
    }

    // MARK: - Empty State

    @Test("Empty state hints are non-empty localized strings")
    func testEmptyStateHintsAreLocalized() {
        #expect(!AccessibilityHelper.emptySupplementsHint.isEmpty)
        #expect(!AccessibilityHelper.emptyRecordsHint.isEmpty)
        #expect(!AccessibilityHelper.emptyHistoryHint.isEmpty)
    }

    // MARK: - Dynamic Labels

    @Test("Today summary label includes counts")
    func testTodaySummaryLabel() {
        let label = AccessibilityHelper.todaySummaryLabel(recordCount: 5, nutrientCount: 3)
        #expect(label.contains("5"))
        #expect(label.contains("3"))
    }

    @Test("Nutrient progress label includes percentage")
    func testNutrientProgressLabel() {
        let label = AccessibilityHelper.nutrientProgressLabel(
            nutrient: .vitaminC,
            percentage: 75.0
        )
        #expect(label.contains("75"))
    }

    @Test("Nutrient progress hint varies by percentage")
    func testNutrientProgressHint() {
        let low = AccessibilityHelper.nutrientProgressHint(percentage: 25)
        let high = AccessibilityHelper.nutrientProgressHint(percentage: 100)
        let mid = AccessibilityHelper.nutrientProgressHint(percentage: 75)

        #expect(!low.isEmpty)
        #expect(!high.isEmpty)
        #expect(!mid.isEmpty)
        // They should be different messages for different ranges
        #expect(low != high)
    }

    @Test("Intake record label includes supplement name")
    func testIntakeRecordLabel() {
        let label = AccessibilityHelper.intakeRecordLabel(
            supplementName: "Vitamin D",
            amount: 2.0,
            date: Date()
        )
        #expect(label.contains("Vitamin D"))
    }

    @Test("Error label includes error message")
    func testErrorLabel() {
        let label = AccessibilityHelper.errorLabel("Network timeout")
        #expect(label.contains("Network timeout"))
    }
}
