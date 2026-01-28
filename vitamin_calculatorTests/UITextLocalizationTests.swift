//
//  UITextLocalizationTests.swift
//  vitamin_calculatorTests
//
//  Created by Claude Code on 28.01.26.
//

import Testing
import Foundation
@testable import vitamin_calculator

@Suite("UI Text Localization Tests")
struct UITextLocalizationTests {

    // MARK: - Tab Navigation Tests

    @Test("Tab labels are localized in German")
    func testTabLabelsGerman() {
        let bundle = getBundle(for: "de")

        #expect(NSLocalizedString("tab_dashboard", bundle: bundle, comment: "") == "Übersicht")
        #expect(NSLocalizedString("tab_record", bundle: bundle, comment: "") == "Aufzeichnen")
        #expect(NSLocalizedString("tab_supplements", bundle: bundle, comment: "") == "Supplemente")
        #expect(NSLocalizedString("tab_history", bundle: bundle, comment: "") == "Verlauf")
        #expect(NSLocalizedString("tab_profile", bundle: bundle, comment: "") == "Profil")
    }

    @Test("Tab labels are localized in English")
    func testTabLabelsEnglish() {
        let bundle = getBundle(for: "en")

        #expect(NSLocalizedString("tab_dashboard", bundle: bundle, comment: "") == "Dashboard")
        #expect(NSLocalizedString("tab_record", bundle: bundle, comment: "") == "Record")
        #expect(NSLocalizedString("tab_supplements", bundle: bundle, comment: "") == "Supplements")
        #expect(NSLocalizedString("tab_history", bundle: bundle, comment: "") == "History")
        #expect(NSLocalizedString("tab_profile", bundle: bundle, comment: "") == "Profile")
    }

    @Test("Tab labels are localized in Chinese")
    func testTabLabelsChinese() {
        let bundle = getBundle(for: "zh-Hans")

        #expect(NSLocalizedString("tab_dashboard", bundle: bundle, comment: "") == "首页")
        #expect(NSLocalizedString("tab_record", bundle: bundle, comment: "") == "记录")
        #expect(NSLocalizedString("tab_supplements", bundle: bundle, comment: "") == "补剂")
        #expect(NSLocalizedString("tab_history", bundle: bundle, comment: "") == "历史")
        #expect(NSLocalizedString("tab_profile", bundle: bundle, comment: "") == "我的")
    }

    // MARK: - Common UI Text Tests

    @Test("Common buttons are localized in German")
    func testCommonButtonsGerman() {
        let bundle = getBundle(for: "de")

        #expect(NSLocalizedString("button_save", bundle: bundle, comment: "") == "Speichern")
        #expect(NSLocalizedString("button_cancel", bundle: bundle, comment: "") == "Abbrechen")
        #expect(NSLocalizedString("button_done", bundle: bundle, comment: "") == "Fertig")
        #expect(NSLocalizedString("button_ok", bundle: bundle, comment: "") == "OK")
        #expect(NSLocalizedString("button_delete", bundle: bundle, comment: "") == "Löschen")
        #expect(NSLocalizedString("button_edit", bundle: bundle, comment: "") == "Bearbeiten")
    }

    @Test("Common buttons are localized in English")
    func testCommonButtonsEnglish() {
        let bundle = getBundle(for: "en")

        #expect(NSLocalizedString("button_save", bundle: bundle, comment: "") == "Save")
        #expect(NSLocalizedString("button_cancel", bundle: bundle, comment: "") == "Cancel")
        #expect(NSLocalizedString("button_done", bundle: bundle, comment: "") == "Done")
        #expect(NSLocalizedString("button_ok", bundle: bundle, comment: "") == "OK")
        #expect(NSLocalizedString("button_delete", bundle: bundle, comment: "") == "Delete")
        #expect(NSLocalizedString("button_edit", bundle: bundle, comment: "") == "Edit")
    }

    @Test("Common buttons are localized in Chinese")
    func testCommonButtonsChinese() {
        let bundle = getBundle(for: "zh-Hans")

        #expect(NSLocalizedString("button_save", bundle: bundle, comment: "") == "保存")
        #expect(NSLocalizedString("button_cancel", bundle: bundle, comment: "") == "取消")
        #expect(NSLocalizedString("button_done", bundle: bundle, comment: "") == "完成")
        #expect(NSLocalizedString("button_ok", bundle: bundle, comment: "") == "确定")
        #expect(NSLocalizedString("button_delete", bundle: bundle, comment: "") == "删除")
        #expect(NSLocalizedString("button_edit", bundle: bundle, comment: "") == "编辑")
    }

    // MARK: - User Type Localization Tests

    @Test("User types are localized in German")
    func testUserTypesGerman() {
        let bundle = getBundle(for: "de")

        #expect(NSLocalizedString("user_type_adult_male", bundle: bundle, comment: "") == "Erwachsener Mann")
        #expect(NSLocalizedString("user_type_adult_female", bundle: bundle, comment: "") == "Erwachsene Frau")
        #expect(NSLocalizedString("user_type_child", bundle: bundle, comment: "") == "Kind")
    }

    @Test("User types are localized in English")
    func testUserTypesEnglish() {
        let bundle = getBundle(for: "en")

        #expect(NSLocalizedString("user_type_adult_male", bundle: bundle, comment: "") == "Adult Male")
        #expect(NSLocalizedString("user_type_adult_female", bundle: bundle, comment: "") == "Adult Female")
        #expect(NSLocalizedString("user_type_child", bundle: bundle, comment: "") == "Child")
    }

    @Test("User types are localized in Chinese")
    func testUserTypesChinese() {
        let bundle = getBundle(for: "zh-Hans")

        #expect(NSLocalizedString("user_type_adult_male", bundle: bundle, comment: "") == "成年男性")
        #expect(NSLocalizedString("user_type_adult_female", bundle: bundle, comment: "") == "成年女性")
        #expect(NSLocalizedString("user_type_child", bundle: bundle, comment: "") == "儿童")
    }

    // MARK: - Section Headers Tests

    @Test("Section headers are localized in German")
    func testSectionHeadersGerman() {
        let bundle = getBundle(for: "de")

        #expect(NSLocalizedString("section_settings", bundle: bundle, comment: "") == "Einstellungen")
        #expect(NSLocalizedString("section_data", bundle: bundle, comment: "") == "Daten")
        #expect(NSLocalizedString("section_statistics", bundle: bundle, comment: "") == "Statistiken")
        #expect(NSLocalizedString("section_about", bundle: bundle, comment: "") == "Über")
    }

    @Test("Section headers are localized in English")
    func testSectionHeadersEnglish() {
        let bundle = getBundle(for: "en")

        #expect(NSLocalizedString("section_settings", bundle: bundle, comment: "") == "Settings")
        #expect(NSLocalizedString("section_data", bundle: bundle, comment: "") == "Data")
        #expect(NSLocalizedString("section_statistics", bundle: bundle, comment: "") == "Statistics")
        #expect(NSLocalizedString("section_about", bundle: bundle, comment: "") == "About")
    }

    @Test("Section headers are localized in Chinese")
    func testSectionHeadersChinese() {
        let bundle = getBundle(for: "zh-Hans")

        #expect(NSLocalizedString("section_settings", bundle: bundle, comment: "") == "设置")
        #expect(NSLocalizedString("section_data", bundle: bundle, comment: "") == "数据")
        #expect(NSLocalizedString("section_statistics", bundle: bundle, comment: "") == "统计信息")
        #expect(NSLocalizedString("section_about", bundle: bundle, comment: "") == "关于")
    }

    // MARK: - Loading and Error Messages Tests

    @Test("Loading messages are localized")
    func testLoadingMessagesAllLanguages() {
        let germanBundle = getBundle(for: "de")
        let englishBundle = getBundle(for: "en")
        let chineseBundle = getBundle(for: "zh-Hans")

        #expect(NSLocalizedString("loading", bundle: germanBundle, comment: "") == "Laden...")
        #expect(NSLocalizedString("loading", bundle: englishBundle, comment: "") == "Loading...")
        #expect(NSLocalizedString("loading", bundle: chineseBundle, comment: "") == "加载中...")
    }

    @Test("Error messages are localized")
    func testErrorMessagesAllLanguages() {
        let germanBundle = getBundle(for: "de")
        let englishBundle = getBundle(for: "en")
        let chineseBundle = getBundle(for: "zh-Hans")

        #expect(NSLocalizedString("error", bundle: germanBundle, comment: "") == "Fehler")
        #expect(NSLocalizedString("error", bundle: englishBundle, comment: "") == "Error")
        #expect(NSLocalizedString("error", bundle: chineseBundle, comment: "") == "错误")
    }

    // MARK: - Dashboard Specific Tests

    @Test("Dashboard strings are localized in German")
    func testDashboardGerman() {
        let bundle = getBundle(for: "de")

        #expect(NSLocalizedString("dashboard_intake_records", bundle: bundle, comment: "") == "Einnahmeprotokolle")
        #expect(NSLocalizedString("dashboard_nutrients", bundle: bundle, comment: "") == "Nährstoffe")
        #expect(NSLocalizedString("dashboard_no_records", bundle: bundle, comment: "") == "Keine Einträge für heute")
    }

    @Test("Dashboard strings are localized in English")
    func testDashboardEnglish() {
        let bundle = getBundle(for: "en")

        #expect(NSLocalizedString("dashboard_intake_records", bundle: bundle, comment: "") == "Intake Records")
        #expect(NSLocalizedString("dashboard_nutrients", bundle: bundle, comment: "") == "Nutrients")
        #expect(NSLocalizedString("dashboard_no_records", bundle: bundle, comment: "") == "No records for today")
    }

    @Test("Dashboard strings are localized in Chinese")
    func testDashboardChinese() {
        let bundle = getBundle(for: "zh-Hans")

        #expect(NSLocalizedString("dashboard_intake_records", bundle: bundle, comment: "") == "摄入记录")
        #expect(NSLocalizedString("dashboard_nutrients", bundle: bundle, comment: "") == "营养素")
        #expect(NSLocalizedString("dashboard_no_records", bundle: bundle, comment: "") == "今日暂无摄入记录")
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
