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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                Text(formattedDate)
                    .font(.headline)
                Spacer()
            }

            Divider()

            if let summary = summary {
                HStack(spacing: 24) {
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
            } else {
                Text("今日暂无摄入记录")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
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
struct NutrientProgressRing: View, Equatable {
    let nutrient: NutrientType
    let summary: DailyIntakeSummary
    let userType: UserType

    private var percentage: Double {
        summary.completionPercentage(for: nutrient, userType: userType)
    }

    private var status: NutrientStatus {
        summary.status(for: nutrient, userType: userType)
    }

    private var statusColor: Color {
        switch status {
        case .none:
            return .gray
        case .insufficient:
            return .orange
        case .normal:
            return .green
        case .excessive:
            return .red
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: min(percentage / 100, 1.0))
                    .stroke(statusColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: percentage)

                VStack(spacing: 2) {
                    Text("\(Int(min(percentage, 999)))%")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                }
            }
            .frame(width: 60, height: 60)

            Text(nutrient.localizedName)
                .font(.caption)
                .lineLimit(1)
                .foregroundStyle(.primary)
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("健康提示")
                .font(.headline)

            ForEach(tips, id: \.self) { tip in
                HealthTipCard(tip: tip)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct HealthTipCard: View {
    let tip: HealthTip

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
            return .red
        case .suggestion:
            return .orange
        case .info:
            return .blue
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                if let nutrient = tip.nutrient {
                    Text(nutrient.localizedName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(tip.message)
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding()
        .background(iconColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    DashboardView()
}
