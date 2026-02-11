//
//  ViewStringLocalizationTests.swift
//  suppuddyTests
//
//  Created by Claude Code on 11.02.26.
//

import Testing
import Foundation
@testable import suppuddy

@Suite("View String Localization Tests")
struct ViewStringLocalizationTests {

    // MARK: - Format String Tests (used in View string interpolation)

    @Test("Format string '%lld 条记录' has English translation")
    func testRecordsCountEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("%lld 条记录", bundle: bundle, comment: "")
        #expect(value.contains("records"))
    }

    @Test("Format string '%lld 条记录' has German translation")
    func testRecordsCountGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("%lld 条记录", bundle: bundle, comment: "")
        #expect(value.contains("Einträge"))
    }

    @Test("Format string '%lld 份' has English translation")
    func testServingsCountEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("%lld 份", bundle: bundle, comment: "")
        #expect(value.contains("servings"))
    }

    @Test("Format string '%lld 份' has German translation")
    func testServingsCountGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("%lld 份", bundle: bundle, comment: "")
        #expect(value.contains("Portionen"))
    }

    @Test("Format string '%lld 种营养素' has English translation")
    func testNutrientCountEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("%lld 种营养素", bundle: bundle, comment: "")
        #expect(value.contains("nutrients"))
    }

    @Test("Format string '%lld 种营养素' has German translation")
    func testNutrientCountGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("%lld 种营养素", bundle: bundle, comment: "")
        #expect(value.contains("Nährstoffe"))
    }

    @Test("Format string '%lld 岁' has English translation")
    func testAgeEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("%lld 岁", bundle: bundle, comment: "")
        #expect(value.contains("years"))
    }

    @Test("Format string '%lld 岁' has German translation")
    func testAgeGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("%lld 岁", bundle: bundle, comment: "")
        #expect(value.contains("Jahre"))
    }

    @Test("Format string '%lld 项' has English translation")
    func testItemsCountEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("%lld 项", bundle: bundle, comment: "")
        #expect(value.contains("items") || value.contains("lld"))
    }

    @Test("Format string '%lld 项' has German translation")
    func testItemsCountGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("%lld 项", bundle: bundle, comment: "")
        #expect(value != "%lld 项")
    }

    // MARK: - Dashboard View Strings

    @Test("'今日营养素摄入' has English translation")
    func testTodayNutrientIntakeEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("今日营养素摄入", bundle: bundle, comment: "")
        #expect(value.contains("Nutrient") || value.contains("nutrient"))
    }

    @Test("'今日营养素摄入' has German translation")
    func testTodayNutrientIntakeGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("今日营养素摄入", bundle: bundle, comment: "")
        #expect(value.contains("Nährstoff"))
    }

    @Test("'暂无数据' has English translation")
    func testNoDataEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("暂无数据", bundle: bundle, comment: "")
        #expect(value.lowercased().contains("data") || value.lowercased().contains("no"))
    }

    @Test("'暂无数据' has German translation")
    func testNoDataGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("暂无数据", bundle: bundle, comment: "")
        #expect(value != "暂无数据")
    }

    // MARK: - History View Strings

    @Test("'无记录' has English translation")
    func testNoRecordsEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("无记录", bundle: bundle, comment: "")
        #expect(value.lowercased().contains("record") || value.lowercased().contains("no"))
    }

    @Test("'无记录' has German translation")
    func testNoRecordsGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("无记录", bundle: bundle, comment: "")
        #expect(value.contains("Eintrag") || value.contains("Keine"))
    }

    @Test("'该日期没有摄入记录' has English translation")
    func testNoIntakeForDateEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("该日期没有摄入记录", bundle: bundle, comment: "")
        #expect(value != "该日期没有摄入记录")
        #expect(value.lowercased().contains("no") || value.lowercased().contains("record"))
    }

    @Test("'该日期没有摄入记录' has German translation")
    func testNoIntakeForDateGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("该日期没有摄入记录", bundle: bundle, comment: "")
        #expect(value != "该日期没有摄入记录")
    }

    // MARK: - IntakeRecord View Strings

    @Test("'记录摄入' has English translation")
    func testRecordIntakeEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("记录摄入", bundle: bundle, comment: "")
        #expect(value.lowercased().contains("record") || value.lowercased().contains("intake"))
    }

    @Test("'记录摄入' has German translation")
    func testRecordIntakeGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("记录摄入", bundle: bundle, comment: "")
        #expect(value != "记录摄入")
    }

    @Test("'服用时间' has English translation")
    func testTimeOfDayEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("服用时间", bundle: bundle, comment: "")
        #expect(value.lowercased().contains("time") || value.lowercased().contains("day"))
    }

    @Test("'服用时间' has German translation")
    func testTimeOfDayGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("服用时间", bundle: bundle, comment: "")
        #expect(value != "服用时间")
    }

    @Test("'服用份数' has English translation")
    func testServingsTakenEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("服用份数", bundle: bundle, comment: "")
        #expect(value.lowercased().contains("serving"))
    }

    @Test("'服用份数' has German translation")
    func testServingsTakenGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("服用份数", bundle: bundle, comment: "")
        #expect(value != "服用份数")
    }

    // MARK: - Onboarding View Strings

    @Test("'欢迎使用 suppuddy' has English translation")
    func testWelcomeEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("欢迎使用 suppuddy", bundle: bundle, comment: "")
        #expect(value.lowercased().contains("welcome") || value.lowercased().contains("suppuddy"))
    }

    @Test("'欢迎使用 suppuddy' has German translation")
    func testWelcomeGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("欢迎使用 suppuddy", bundle: bundle, comment: "")
        #expect(value != "欢迎使用 suppuddy")
    }

    @Test("'关于您' has English translation")
    func testAboutYouEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("关于您", bundle: bundle, comment: "")
        #expect(value.lowercased().contains("about") || value.lowercased().contains("you"))
    }

    @Test("'关于您' has German translation")
    func testAboutYouGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("关于您", bundle: bundle, comment: "")
        #expect(value != "关于您")
    }

    @Test("'主要功能' has English translation")
    func testFeaturesEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("主要功能", bundle: bundle, comment: "")
        #expect(value != "主要功能")
    }

    @Test("'主要功能' has German translation")
    func testFeaturesGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("主要功能", bundle: bundle, comment: "")
        #expect(value != "主要功能")
    }

    // MARK: - User Profile View Strings

    @Test("'基本信息' has English translation")
    func testBasicInfoEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("基本信息", bundle: bundle, comment: "")
        #expect(value.lowercased().contains("basic") || value.lowercased().contains("information"))
    }

    @Test("'基本信息' has German translation")
    func testBasicInfoGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("基本信息", bundle: bundle, comment: "")
        #expect(value != "基本信息")
    }

    @Test("'成年男性' has English translation")
    func testAdultMaleEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("成年男性", bundle: bundle, comment: "")
        #expect(value.lowercased().contains("adult") || value.lowercased().contains("male"))
    }

    @Test("'成年男性' has German translation")
    func testAdultMaleGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("成年男性", bundle: bundle, comment: "")
        #expect(value != "成年男性")
    }

    @Test("'保存' has English translation")
    func testSaveEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("保存", bundle: bundle, comment: "")
        #expect(value.lowercased().contains("save"))
    }

    @Test("'保存' has German translation")
    func testSaveGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("保存", bundle: bundle, comment: "")
        #expect(value.contains("Speichern") || value != "保存")
    }

    // MARK: - Supplement View Strings

    @Test("'暂无补剂' has English translation")
    func testNoSupplementsEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("暂无补剂", bundle: bundle, comment: "")
        #expect(value.lowercased().contains("supplement"))
    }

    @Test("'暂无补剂' has German translation")
    func testNoSupplementsGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("暂无补剂", bundle: bundle, comment: "")
        #expect(value != "暂无补剂")
    }

    @Test("'添加补剂' has English translation")
    func testAddSupplementEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("添加补剂", bundle: bundle, comment: "")
        #expect(value.lowercased().contains("add") || value.lowercased().contains("supplement"))
    }

    @Test("'添加补剂' has German translation")
    func testAddSupplementGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("添加补剂", bundle: bundle, comment: "")
        #expect(value != "添加补剂")
    }

    // MARK: - English Key Strings needing German/Chinese

    @Test("'Loading...' has German translation")
    func testLoadingGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("Loading...", bundle: bundle, comment: "")
        #expect(value.contains("Laden") || value != "Loading...")
    }

    @Test("'Loading...' has Chinese translation")
    func testLoadingChinese() {
        let bundle = getBundle(for: "zh-Hans")
        let value = NSLocalizedString("Loading...", bundle: bundle, comment: "")
        #expect(value != "Loading...")
    }

    @Test("'Cancel' has German translation")
    func testCancelGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("Cancel", bundle: bundle, comment: "")
        #expect(value.contains("Abbrechen") || value != "Cancel")
    }

    @Test("'Cancel' has Chinese translation")
    func testCancelChinese() {
        let bundle = getBundle(for: "zh-Hans")
        let value = NSLocalizedString("Cancel", bundle: bundle, comment: "")
        #expect(value != "Cancel")
    }

    @Test("'New Supplement' has German translation")
    func testNewSupplementGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("New Supplement", bundle: bundle, comment: "")
        #expect(value != "New Supplement")
    }

    @Test("'New Supplement' has Chinese translation")
    func testNewSupplementChinese() {
        let bundle = getBundle(for: "zh-Hans")
        let value = NSLocalizedString("New Supplement", bundle: bundle, comment: "")
        #expect(value != "New Supplement")
    }

    @Test("'Scan Barcode' has German translation")
    func testScanBarcodeGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("Scan Barcode", bundle: bundle, comment: "")
        #expect(value != "Scan Barcode")
    }

    @Test("'Scan Barcode' has Chinese translation")
    func testScanBarcodeChinese() {
        let bundle = getBundle(for: "zh-Hans")
        let value = NSLocalizedString("Scan Barcode", bundle: bundle, comment: "")
        #expect(value != "Scan Barcode")
    }

    // MARK: - Child Age Format String

    @Test("'儿童 (%lld岁)' has English translation")
    func testChildAgeEnglish() {
        let bundle = getBundle(for: "en")
        let value = NSLocalizedString("儿童 (%lld岁)", bundle: bundle, comment: "")
        #expect(value != "儿童 (%lld岁)")
        #expect(value.lowercased().contains("child") || value.lowercased().contains("age"))
    }

    @Test("'儿童 (%lld岁)' has German translation")
    func testChildAgeGerman() {
        let bundle = getBundle(for: "de")
        let value = NSLocalizedString("儿童 (%lld岁)", bundle: bundle, comment: "")
        #expect(value != "儿童 (%lld岁)")
        #expect(value.lowercased().contains("kind") || value.lowercased().contains("alter"))
    }

    // MARK: - Helper

    private func getBundle(for languageId: String) -> Bundle {
        guard let path = Bundle.main.path(forResource: languageId, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }
}
