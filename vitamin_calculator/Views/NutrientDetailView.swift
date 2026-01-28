//
//  NutrientDetailView.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import SwiftUI
import SwiftData
import Charts

/// Detailed view for a specific nutrient showing current status, trend chart, and sources
struct NutrientDetailView: View {
    let nutrientType: NutrientType
    let modelContext: ModelContext

    @State private var viewModel: NutrientChartViewModel?

    var body: some View {
        Group {
            if let viewModel = viewModel {
                detailContent(viewModel: viewModel)
            } else {
                ProgressView("加载中...")
            }
        }
        .navigationTitle(nutrientType.localizedName)
        .navigationBarTitleDisplayMode(.large)
        .task {
            if viewModel == nil {
                viewModel = NutrientChartViewModel(modelContext: modelContext)
                await viewModel?.selectNutrient(nutrientType)
            }
        }
    }

    @ViewBuilder
    private func detailContent(viewModel: NutrientChartViewModel) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current Status Card
                CurrentStatusCard(
                    nutrient: nutrientType,
                    averageValue: viewModel.averageValue,
                    recommendedValue: viewModel.recommendedValue
                )

                // Time Range Picker
                TimeRangePicker(
                    selectedRange: viewModel.selectedTimeRange
                ) { newRange in
                    Task {
                        await viewModel.changeTimeRange(newRange)
                    }
                }

                // Trend Chart
                TrendChartView(
                    dataPoints: viewModel.chartData,
                    recommendedValue: viewModel.recommendedValue,
                    unit: nutrientType.unit
                )

                // Nutrient Info Card
                NutrientInfoCard(nutrient: nutrientType)
            }
            .padding()
        }
        .refreshable {
            await viewModel.loadChartData()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
}

// MARK: - Current Status Card

struct CurrentStatusCard: View {
    let nutrient: NutrientType
    let averageValue: Double
    let recommendedValue: Double

    private var percentage: Double {
        guard recommendedValue > 0 else { return 0 }
        return (averageValue / recommendedValue) * 100
    }

    private var statusColor: Color {
        if percentage < 80 {
            return .orange
        } else if percentage > 150 {
            return .red
        } else {
            return .green
        }
    }

    private var statusText: String {
        if percentage < 80 {
            return "摄入不足"
        } else if percentage > 150 {
            return "摄入过量"
        } else {
            return "摄入正常"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("平均每日摄入")
                    .font(.headline)
                Spacer()
                Text(statusText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
            }

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", averageValue))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(statusColor)

                Text(nutrient.unit)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(statusColor)
                            .frame(width: min(geometry.size.width * (percentage / 100), geometry.size.width), height: 8)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("0%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("推荐: \(String(format: "%.1f", recommendedValue)) \(nutrient.unit)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("100%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Time Range Picker

struct TimeRangePicker: View {
    let selectedRange: TimeRange
    let onSelect: (TimeRange) -> Void

    var body: some View {
        Picker("时间范围", selection: Binding(
            get: { selectedRange },
            set: { onSelect($0) }
        )) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.displayName).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - Trend Chart View

struct TrendChartView: View {
    let dataPoints: [DataPoint]
    let recommendedValue: Double
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("摄入趋势")
                .font(.headline)

            if dataPoints.isEmpty {
                ContentUnavailableView(
                    "暂无数据",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("记录摄入后查看趋势")
                )
                .frame(height: 200)
            } else {
                Chart {
                    ForEach(dataPoints, id: \.date) { point in
                        LineMark(
                            x: .value("日期", point.date),
                            y: .value("摄入量", point.value)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("日期", point.date),
                            y: .value("摄入量", point.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .blue.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("日期", point.date),
                            y: .value("摄入量", point.value)
                        )
                        .foregroundStyle(.blue)
                    }

                    if recommendedValue > 0 {
                        RuleMark(y: .value("推荐值", recommendedValue))
                            .foregroundStyle(.green.opacity(0.7))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                            .annotation(position: .top, alignment: .trailing) {
                                Text("推荐值")
                                    .font(.caption2)
                                    .foregroundStyle(.green)
                            }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(Int(doubleValue))")
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        AxisGridLine()
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Nutrient Info Card

struct NutrientInfoCard: View {
    let nutrient: NutrientType

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("营养素信息")
                .font(.headline)

            Divider()

            InfoRow(label: "名称", value: nutrient.localizedName)
            InfoRow(label: "单位", value: nutrient.unit)
            InfoRow(label: "类型", value: nutrient.isVitamin ? "维生素" : "矿物质")
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        NutrientDetailView(
            nutrientType: .vitaminC,
            modelContext: try! ModelContainer(
                for: UserProfile.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            ).mainContext
        )
    }
}
