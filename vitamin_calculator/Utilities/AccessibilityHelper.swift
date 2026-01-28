//
//  AccessibilityHelper.swift
//  vitamin_calculator
//
//  Created by Claude Code on 28.01.26.
//  Sprint 7 Phase 2: Accessibility support utilities
//

import SwiftUI
import Foundation

/// Provides consistent accessibility labels and hints throughout the app
enum AccessibilityHelper {

    // MARK: - Tab Bar Labels

    static let tabDashboard = "首页"
    static let tabDashboardHint = "查看今日营养素摄入总结"

    static let tabRecord = "记录摄入"
    static let tabRecordHint = "记录补剂摄入"

    static let tabSupplements = "补剂列表"
    static let tabSupplementsHint = "管理补剂"

    static let tabHistory = "历史记录"
    static let tabHistoryHint = "查看历史摄入记录"

    static let tabProfile = "个人资料"
    static let tabProfileHint = "查看和编辑个人设置"

    // MARK: - Dashboard Accessibility

    static func todaySummaryLabel(recordCount: Int, nutrientCount: Int) -> String {
        "今日摄入总结：\(recordCount)条记录，覆盖\(nutrientCount)种营养素"
    }

    static func nutrientProgressLabel(nutrient: NutrientType, percentage: Double) -> String {
        "\(nutrient.localizedName)，完成\(Int(percentage))%"
    }

    static func nutrientProgressHint(percentage: Double) -> String {
        if percentage < 50 {
            return "摄入不足，建议增加"
        } else if percentage >= 100 {
            return "已达到或超过推荐量"
        } else {
            return "进展良好"
        }
    }

    static func healthTipLabel(type: TipType, nutrient: NutrientType?, message: String) -> String {
        let prefix: String
        switch type {
        case .warning:
            prefix = "警告"
        case .suggestion:
            prefix = "建议"
        case .info:
            prefix = "提示"
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
            label += "，品牌：\(brand)"
        }
        label += "，每次\(servingSize)，每天\(servingsPerDay)次"
        label += "，包含\(nutrientCount)种营养素"
        if !isActive {
            label += "，已停用"
        }
        return label
    }

    static let supplementAddButton = "添加补剂"
    static let supplementSortButton = "排序选项"
    static let supplementDeleteAction = "删除补剂"
    static let supplementEditAction = "编辑补剂"
    static let supplementActivateAction = "启用补剂"
    static let supplementDeactivateAction = "停用补剂"

    // MARK: - Intake Record Accessibility

    static func intakeRecordLabel(
        supplementName: String,
        amount: Double,
        date: Date
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        let dateString = formatter.string(from: date)
        return "\(supplementName)，摄入量：\(amount)，时间：\(dateString)"
    }

    static let recordIntakeButton = "记录摄入"
    static let recordIntakeHint = "选择补剂并记录摄入量"

    // MARK: - Button Accessibility

    static let addButton = "添加"
    static let editButton = "编辑"
    static let deleteButton = "删除"
    static let saveButton = "保存"
    static let cancelButton = "取消"
    static let closeButton = "关闭"
    static let doneButton = "完成"
    static let nextButton = "下一步"
    static let previousButton = "上一步"
    static let retryButton = "重试"

    // MARK: - Status Accessibility

    static let loadingStatus = "加载中"
    static let refreshingStatus = "刷新中"
    static let savingStatus = "保存中"
    static let deletingStatus = "删除中"

    // MARK: - Error Accessibility

    static func errorLabel(_ message: String) -> String {
        "错误：\(message)"
    }

    // MARK: - Empty State Accessibility

    static let emptySupplementsHint = "尚无补剂，点击添加按钮创建第一个补剂"
    static let emptyRecordsHint = "尚无摄入记录，记录补剂摄入后查看"
    static let emptyHistoryHint = "尚无历史记录"
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
