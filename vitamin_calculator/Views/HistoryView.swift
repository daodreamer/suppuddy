//
//  HistoryView.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import SwiftUI
import SwiftData

/// View for displaying historical intake records with calendar navigation
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HistoryViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    historyContent(viewModel: viewModel)
                } else {
                    ProgressView("加载中...")
                }
            }
            .navigationTitle("历史记录")
        }
        .task {
            if viewModel == nil {
                viewModel = HistoryViewModel(modelContext: modelContext)
                await viewModel?.loadCalendarData(for: Date())
                await viewModel?.loadRecords(for: Date())
            }
        }
    }

    @ViewBuilder
    private func historyContent(viewModel: HistoryViewModel) -> some View {
        VStack(spacing: 0) {
            // Calendar Header
            CalendarHeaderView(
                currentMonth: viewModel.selectedDate,
                onMonthChange: { newMonth in
                    Task {
                        await viewModel.loadCalendarData(for: newMonth)
                    }
                }
            )

            // Calendar Grid
            CalendarGridView(
                selectedDate: viewModel.selectedDate,
                calendarData: viewModel.calendarData,
                onDateSelected: { date in
                    Task {
                        await viewModel.loadRecords(for: date)
                    }
                }
            )

            Divider()
                .padding(.top, 8)

            // Selected Day Records
            SelectedDayRecordsView(
                date: viewModel.selectedDate,
                records: viewModel.records
            )
        }
        .refreshable {
            await viewModel.loadCalendarData(for: viewModel.selectedDate)
            await viewModel.loadRecords(for: viewModel.selectedDate)
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

// MARK: - Calendar Header View

struct CalendarHeaderView: View {
    let currentMonth: Date
    let onMonthChange: (Date) -> Void

    private let calendar = Calendar.current

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: currentMonth)
    }

    var body: some View {
        HStack {
            Button {
                if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
                    onMonthChange(previousMonth)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            Spacer()

            Text(monthYearString)
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Button {
                if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
                    onMonthChange(nextMonth)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

// MARK: - Calendar Grid View

struct CalendarGridView: View {
    let selectedDate: Date
    let calendarData: [Date: IntakeStatus]
    let onDateSelected: (Date) -> Void

    private let calendar = Calendar.current
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]

    private var daysInMonth: [Date?] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmptyDays = firstWeekday - 1

        var days: [Date?] = Array(repeating: nil, count: leadingEmptyDays)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }

        // Fill remaining cells to complete the grid
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    var body: some View {
        VStack(spacing: 8) {
            // Weekday headers
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            status: calendarData[calendar.startOfDay(for: date)]
                        ) {
                            onDateSelected(date)
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let status: IntakeStatus?
    let onTap: () -> Void

    private let calendar = Calendar.current

    private var dayNumber: String {
        "\(calendar.component(.day, from: date))"
    }

    private var statusColor: Color {
        guard let status = status else { return .clear }
        switch status {
        case .complete:
            return .green
        case .partial:
            return .orange
        case .none:
            return .clear
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(dayNumber)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? .white : (isToday ? .blue : .primary))

                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
                    .opacity(status != nil && status != IntakeStatus.none ? 1 : 0)
            }
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.1) : Color.clear))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Selected Day Records View

struct SelectedDayRecordsView: View {
    let date: Date
    let records: [IntakeRecord]

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formattedDate)
                    .font(.headline)

                Spacer()

                if !records.isEmpty {
                    Text("\(records.count) 条记录")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)

            if records.isEmpty {
                ContentUnavailableView(
                    "无记录",
                    systemImage: "doc.text",
                    description: Text("该日期没有摄入记录")
                )
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(records, id: \.persistentModelID) { record in
                        HistoryRecordRow(record: record)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

struct HistoryRecordRow: View {
    let record: IntakeRecord

    private var timeIcon: String {
        switch record.timeOfDay {
        case .morning:
            return "sunrise.fill"
        case .noon:
            return "sun.max.fill"
        case .evening:
            return "sunset.fill"
        case .night:
            return "moon.fill"
        }
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: record.createdAt)
    }

    var body: some View {
        HStack {
            Image(systemName: timeIcon)
                .foregroundStyle(.orange)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(record.supplementName)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(record.timeOfDay.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(record.servingsTaken) 份")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(record.nutrients.count) 种营养素")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(formattedTime)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
}
