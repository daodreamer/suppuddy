//
//  IntakeRecordView.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import SwiftUI
import SwiftData

/// View for recording daily supplement intake
struct IntakeRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: IntakeRecordViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    recordContent(viewModel: viewModel)
                } else {
                    ProgressView("加载中...")
                }
            }
            .navigationTitle("记录摄入")
        }
        .task {
            if viewModel == nil {
                let intakeService = IntakeService()
                viewModel = IntakeRecordViewModel(modelContext: modelContext, intakeService: intakeService)
                await viewModel?.loadData()
            }
        }
    }

    @ViewBuilder
    private func recordContent(viewModel: IntakeRecordViewModel) -> some View {
        List {
            // Supplement Selection Section
            Section("选择补剂") {
                if viewModel.availableSupplements.isEmpty {
                    ContentUnavailableView(
                        "暂无补剂",
                        systemImage: "pills",
                        description: Text("请先添加补剂")
                    )
                } else {
                    ForEach(viewModel.availableSupplements, id: \.persistentModelID) { supplement in
                        SupplementSelectionRow(
                            supplement: supplement,
                            isSelected: viewModel.selectedSupplement?.persistentModelID == supplement.persistentModelID
                        ) {
                            viewModel.selectedSupplement = supplement
                        }
                    }
                }
            }

            // Time of Day Section
            Section("服用时间") {
                Picker("时段", selection: Binding(
                    get: { viewModel.selectedTimeOfDay },
                    set: { viewModel.selectedTimeOfDay = $0 }
                )) {
                    ForEach(TimeOfDay.allCases, id: \.self) { time in
                        Text(time.displayName).tag(time)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Serving Count Section
            Section("服用份数") {
                Stepper(
                    value: Binding(
                        get: { viewModel.servingsToRecord },
                        set: { viewModel.servingsToRecord = $0 }
                    ),
                    in: 1...10
                ) {
                    HStack {
                        Text("份数")
                        Spacer()
                        Text("\(viewModel.servingsToRecord)")
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }
                }
            }

            // Record Button
            Section {
                Button {
                    Task {
                        await viewModel.recordIntake()
                    }
                } label: {
                    HStack {
                        Spacer()
                        Label("记录摄入", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                        Spacer()
                    }
                }
                .disabled(viewModel.selectedSupplement == nil || viewModel.isLoading)
                .listRowBackground(viewModel.selectedSupplement == nil ? Color.gray.opacity(0.3) : Color.blue)
                .foregroundStyle(.white)
            }

            // Today's Records Section
            Section("今日记录") {
                if viewModel.todayRecords.isEmpty {
                    Text("今日暂无记录")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(viewModel.todayRecords, id: \.persistentModelID) { record in
                        IntakeRecordRow(record: record)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let record = viewModel.todayRecords[index]
                            Task {
                                await viewModel.deleteRecord(record)
                            }
                        }
                    }
                }
            }
        }
        .refreshable {
            await viewModel.loadData()
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView()
            }
        }
        .alert("错误", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("确定") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !viewModel.todayRecords.isEmpty {
                    Button {
                        Task {
                            await viewModel.undoLastRecord()
                        }
                    } label: {
                        Label("撤销", systemImage: "arrow.uturn.backward")
                    }
                }
            }
        }
    }
}

// MARK: - Supplement Selection Row

struct SupplementSelectionRow: View {
    let supplement: Supplement
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(supplement.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if let brand = supplement.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text("\(supplement.nutrients.count) 种营养素")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Intake Record Row

struct IntakeRecordRow: View {
    let record: IntakeRecord

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.supplementName)
                    .font(.headline)

                HStack(spacing: 8) {
                    Label(record.timeOfDay.displayName, systemImage: timeIcon)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(record.servingsTaken) 份")
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
}

#Preview {
    IntakeRecordView()
}
