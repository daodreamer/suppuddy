//
//  AccessibilityHelper.swift
//  vitamin_calculator
//
//  Created by Claude Code on 28.01.26.
//  Sprint 7 Phase 2: Accessibility support utilities
//  Updated: Localized all strings via String(localized:)
//

import SwiftUI
import Foundation

/// Provides consistent accessibility labels and hints throughout the app
enum AccessibilityHelper {

    // MARK: - Tab Bar Labels

    static let tabDashboard = String(localized: "首页")
    static let tabDashboardHint = String(localized: "查看今日营养素摄入总结")

    static let tabRecord = String(localized: "记录摄入")
    static let tabRecordHint = String(localized: "记录补剂摄入")

    static let tabSupplements = String(localized: "补剂列表")
    static let tabSupplementsHint = String(localized: "管理补剂")

    static let tabHistory = String(localized: "历史记录")
    static let tabHistoryHint = String(localized: "查看历史摄入记录")

    static let tabProfile = String(localized: "个人资料")
    static let tabProfileHint = String(localized: "查看和编辑个人设置")

    // MARK: - Dashboard Accessibility

    static func todaySummaryLabel(recordCount: Int, nutrientCount: Int) -> String {
        String(localized: "今日摄入总结：\(recordCount)条记录，覆盖\(nutrientCount)种营养素")
    }

    static func nutrientProgressLabel(nutrient: NutrientType, percentage: Double) -> String {
        String(localized: "\(nutrient.localizedName)，完成\(Int(percentage))%")
    }

    static func nutrientProgressHint(percentage: Double) -> String {
        if percentage < 50 {
            return String(localized: "摄入不足，建议增加")
        } else if percentage >= 100 {
            return String(localized: "已达到或超过推荐量")
        } else {
            return String(localized: "进展良好")
        }
    }

    static func healthTipLabel(type: TipType, nutrient: NutrientType?, message: String) -> String {
        let prefix: String
        switch type {
        case .warning:
            prefix = String(localized: "警告")
        case .suggestion:
            prefix = String(localized: "建议")
        case .info:
            prefix = String(localized: "提示")
        }

        if let nutrient = nutrient {
            return "\(prefix)：\(nutrient.localizedName)，\(message)"
        } else {
            return "\(prefix)：\(message)"
        }
    }

    // MARK: - Supplement List Accessibility

    static func supplementRowLabel(
        name: String,
        brand: String?,
        servingSize: String,
        servingsPerDay: Int,
        nutrientCount: Int,
        isActive: Bool
    ) -> String {
        var label = name
        if let brand = brand {
            label += String(localized: "，品牌：\(brand)")
        }
        label += String(localized: "，每次\(servingSize)，每天\(servingsPerDay)次")
        label += String(localized: "，包含\(nutrientCount)种营养素")
        if !isActive {
            label += String(localized: "，已停用")
        }
        return label
    }

    static let supplementAddButton = String(localized: "添加补剂")
    static let supplementSortButton = String(localized: "排序选项")
    static let supplementDeleteAction = String(localized: "删除补剂")
    static let supplementEditAction = String(localized: "编辑补剂")
    static let supplementActivateAction = String(localized: "启用补剂")
    static let supplementDeactivateAction = String(localized: "停用补剂")

    // MARK: - Intake Record Accessibility

    static func intakeRecordLabel(
        supplementName: String,
        amount: Double,
        date: Date
    ) -> String {
        let dateString = date.formatted(date: .abbreviated, time: .shortened)
        return String(localized: "\(supplementName)，摄入量：\(amount)，时间：\(dateString)")
    }

    static let recordIntakeButton = String(localized: "记录摄入")
    static let recordIntakeHint = String(localized: "选择补剂并记录摄入量")

    // MARK: - Button Accessibility

    static let addButton = String(localized: "添加")
    static let editButton = String(localized: "编辑")
    static let deleteButton = String(localized: "删除")
    static let saveButton = String(localized: "保存")
    static let cancelButton = String(localized: "取消")
    static let closeButton = String(localized: "关闭")
    static let doneButton = String(localized: "完成")
    static let nextButton = String(localized: "下一步")
    static let previousButton = String(localized: "上一步")
    static let retryButton = String(localized: "重试")

    // MARK: - Status Accessibility

    static let loadingStatus = String(localized: "加载中")
    static let refreshingStatus = String(localized: "刷新中")
    static let savingStatus = String(localized: "保存中")
    static let deletingStatus = String(localized: "删除中")

    // MARK: - Error Accessibility

    static func errorLabel(_ message: String) -> String {
        String(localized: "错误：\(message)")
    }

    // MARK: - Empty State Accessibility

    static let emptySupplementsHint = String(localized: "尚无补剂，点击添加按钮创建第一个补剂")
    static let emptyRecordsHint = String(localized: "尚无摄入记录，记录补剂摄入后查看")
    static let emptyHistoryHint = String(localized: "尚无历史记录")
}

// MARK: - View Extensions for Accessibility

extension View {
    /// Combines accessibility element with custom label
    func accessibilityElement(label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        self.accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }

    /// Marks element as a button with custom label
    func accessibilityButton(label: String, hint: String? = nil) -> some View {
        self.accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }

    /// Marks element as a header
    func accessibilityHeader(_ label: String) -> some View {
        self.accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isHeader)
    }

    /// Marks element as selected
    func accessibilitySelected(_ isSelected: Bool) -> some View {
        self.accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
