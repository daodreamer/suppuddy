//
//  DashboardView.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import SwiftUI
import SwiftData

/// Main dashboard view showing today's intake summary, quick record buttons, and health tips
struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DashboardViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    dashboardContent(viewModel: viewModel)
                } else {
                    ProgressView("加载中...")
                }
            }
            .navigationTitle("首页")
        }
        .task {
            if viewModel == nil {
                let intakeService = IntakeService()
                viewModel = DashboardViewModel(modelContext: modelContext, intakeService: intakeService)
                await viewModel?.loadTodayData()
            }
        }
    }

    @ViewBuilder
    private func dashboardContent(viewModel: DashboardViewModel) -> some View {
        ScrollView {
            // Sprint 7 Phase 1: Using LazyVStack for better performance
            LazyVStack(spacing: 20) {
                // Today's Summary Card
                TodaySummaryCard(summary: viewModel.todaySummary)

                // Nutrient Progress Section
                NutrientProgressSection(summary: viewModel.todaySummary)

                // Health Tips Section
                if !viewModel.healthTips.isEmpty {
                    HealthTipsSection(tips: viewModel.healthTips)
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .alert("错误", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("确定") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Today's Summary Card

struct TodaySummaryCard: View {
    let summary: DailyIntakeSummary?
    @ScaledMetric private var spacing: CGFloat = 12
    @ScaledMetric private var iconSize: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: iconSize))
                    .foregroundStyle(.blue)
                    .accessibilityHidden(true)
                Text(formattedDate)
                    .font(.headline)
                Spacer()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("日期：\(formattedDate)")

            Divider()

            if let summary = summary {
                HStack(spacing: spacing * 2) {
                    StatItem(
                        title: "摄入记录",
                        value: "\(summary.recordCount)",
                        icon: "doc.text.fill",
                        color: .blue
                    )

                    StatItem(
                        title: "营养素",
                        value: "\(summary.coveredNutrients.count)",
                        icon: "leaf.fill",
                        color: .green
                    )
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(AccessibilityHelper.todaySummaryLabel(
                    recordCount: summary.recordCount,
                    nutrientCount: summary.coveredNutrients.count
                ))
            } else {
                Text("今日暂无摄入记录")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, spacing)
                    .accessibilityLabel("今日尚无摄入记录")
                    .accessibilityHint(AccessibilityHelper.emptyRecordsHint)
            }
        }
        .padding(spacing)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: spacing))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    @ScaledMetric private var spacing: CGFloat = 4
    @ScaledMetric private var minHeight: CGFloat = 60

    var body: some View {
        VStack(spacing: spacing) {
            Image(systemName: icon)
                .font(.title2)
                .imageScale(.large)
                .foregroundStyle(color)
                .accessibilityHidden(true)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: minHeight)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title)：\(value)")
    }
}

// MARK: - Nutrient Progress Section

struct NutrientProgressSection: View {
    @Environment(\.modelContext) private var modelContext
    let summary: DailyIntakeSummary?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日营养素摄入")
                .font(.headline)

            if let summary = summary, !summary.coveredNutrients.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(Array(summary.coveredNutrients).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { nutrient in
                        NavigationLink(destination: NutrientDetailView(nutrientType: nutrient, modelContext: modelContext)) {
                            NutrientProgressRing(
                                nutrient: nutrient,
                                summary: summary,
                                userType: .male // Default, should be from user profile
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                ContentUnavailableView(
                    "暂无数据",
                    systemImage: "chart.bar.xaxis",
                    description: Text("记录补剂摄入后查看营养素进度")
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Sprint 7 Phase 1: Optimized with Equatable to reduce redraws
// Sprint 7 Phase 2: Added VoiceOver accessibility, dynamic font, and reduce motion support
struct NutrientProgressRing: View, Equatable {
    let nutrient: NutrientType
    let summary: DailyIntakeSummary
    let userType: UserType

    @ScaledMetric private var ringSize: CGFloat = 60
    @ScaledMetric private var lineWidth: CGFloat = 8
    @ScaledMetric private var spacing: CGFloat = 8
    @ScaledMetric private var padding: CGFloat = 8
    @ScaledMetric private var cornerRadius: CGFloat = 8

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private var percentage: Double {
        summary.completionPercentage(for: nutrient, userType: userType)
    }

    private var status: NutrientStatus {
        summary.status(for: nutrient, userType: userType)
    }

    private var statusColor: Color {
        switch status {
        case .none:
            return AccessibleColors.nutrientNone
        case .insufficient:
            return AccessibleColors.nutrientInsufficient
        case .normal:
            return AccessibleColors.nutrientNormal
        case .excessive:
            return AccessibleColors.nutrientExcessive
        }
    }

    var body: some View {
        VStack(spacing: spacing) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)

                Circle()
                    .trim(from: 0, to: min(percentage / 100, 1.0))
                    .stroke(statusColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animationAccessible(.easeInOut, value: percentage)

                VStack(spacing: 2) {
                    Text("\(Int(min(percentage, 999)))%")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .frame(width: ringSize, height: ringSize)
            .accessibilityHidden(true)

            Text(nutrient.localizedName)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .accessibilityHidden(true)
        }
        .padding(padding)
        .frame(minHeight: ringSize + spacing + 40)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AccessibilityHelper.nutrientProgressLabel(nutrient: nutrient, percentage: percentage))
        .accessibilityHint(AccessibilityHelper.nutrientProgressHint(percentage: percentage))
        .accessibilityAddTraits(.isButton)
    }

    // Equatable implementation to avoid unnecessary redraws
    static func == (lhs: NutrientProgressRing, rhs: NutrientProgressRing) -> Bool {
        lhs.nutrient == rhs.nutrient &&
        lhs.userType == rhs.userType &&
        lhs.percentage == rhs.percentage
    }
}

// MARK: - Health Tips Section

struct HealthTipsSection: View {
    let tips: [HealthTip]

    @ScaledMetric private var spacing: CGFloat = 12
    @ScaledMetric private var padding: CGFloat = 16
    @ScaledMetric private var cornerRadius: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text("健康提示")
                .font(.headline)

            ForEach(tips, id: \.self) { tip in
                HealthTipCard(tip: tip)
            }
        }
        .padding(padding)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct HealthTipCard: View {
    let tip: HealthTip

    @ScaledMetric private var spacing: CGFloat = 12
    @ScaledMetric private var innerSpacing: CGFloat = 4
    @ScaledMetric private var padding: CGFloat = 12
    @ScaledMetric private var cornerRadius: CGFloat = 8

    private var icon: String {
        switch tip.type {
        case .warning:
            return "exclamationmark.triangle.fill"
        case .suggestion:
            return "lightbulb.fill"
        case .info:
            return "info.circle.fill"
        }
    }

    private var iconColor: Color {
        switch tip.type {
        case .warning:
            return AccessibleColors.error
        case .suggestion:
            return AccessibleColors.warning
        case .info:
            return AccessibleColors.info
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.title3)
                .imageScale(.large)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: innerSpacing) {
                if let nutrient = tip.nutrient {
                    Text(nutrient.localizedName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(tip.message)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(padding)
        .background(iconColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AccessibilityHelper.healthTipLabel(
            type: tip.type,
            nutrient: tip.nutrient,
            message: tip.message
        ))
    }
}

#Preview {
    DashboardView()
}
