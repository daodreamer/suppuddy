//
//  DataManagementView.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 5.3
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData

/// View for managing data import and export operations.
/// Provides options to backup data or restore from backup files.
struct DataManagementView: View {
    @State private var viewModel: DataManagementViewModel

    // UI state
    @State private var showingImportPicker = false
    @State private var showingExportOptions = false
    @State private var showingDateRangePicker = false
    @State private var exportStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var exportEndDate = Date()
    @State private var exportType: ExportType = .allData
    @State private var showingImportConfirmation = false
    @State private var selectedImportMode: ImportMode = .merge
    @State private var showingShareSheet = false

    enum ExportType {
        case allData
        case supplements
        case intakeRecords
    }

    init(exportService: DataExportService, importService: DataImportService) {
        self._viewModel = State(initialValue: DataManagementViewModel(
            exportService: exportService,
            importService: importService
        ))
    }

    var body: some View {
        List {
            // Export Section
            Section {
                Button(action: {
                    Task {
                        await viewModel.exportAllData()
                        if viewModel.exportedFileURL != nil {
                            showingShareSheet = true
                        }
                    }
                }) {
                    ExportOptionRow(
                        icon: "square.and.arrow.up.on.square",
                        title: "导出所有数据",
                        description: "以JSON格式导出所有数据"
                    )
                }
                .disabled(viewModel.isExporting || viewModel.isImporting)

                Button(action: {
                    Task {
                        await viewModel.exportSupplements()
                        if viewModel.exportedFileURL != nil {
                            showingShareSheet = true
                        }
                    }
                }) {
                    ExportOptionRow(
                        icon: "pills",
                        title: "导出补剂列表",
                        description: "以CSV格式导出补剂"
                    )
                }
                .disabled(viewModel.isExporting || viewModel.isImporting)

                Button(action: {
                    exportType = .intakeRecords
                    showingDateRangePicker = true
                }) {
                    ExportOptionRow(
                        icon: "calendar",
                        title: "导出摄入记录",
                        description: "以CSV格式导出记录"
                    )
                }
                .disabled(viewModel.isExporting || viewModel.isImporting)
            } header: {
                Text("导出数据")
            } footer: {
                if viewModel.isExporting {
                    HStack {
                        ProgressView()
                        Text("正在导出...")
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Import Section
            Section {
                Button(action: {
                    showingImportPicker = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .frame(width: 24)
                        Text("导入数据")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .disabled(viewModel.isExporting || viewModel.isImporting)
            } header: {
                Text("导入数据")
            } footer: {
                if viewModel.isImporting {
                    HStack {
                        ProgressView()
                        Text("正在处理...")
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Import Preview Section
            if let preview = viewModel.importPreview {
                Section("导入预览") {
                    VStack(alignment: .leading, spacing: 12) {
                        PreviewRow(label: "补剂", count: preview.supplementCount)
                        PreviewRow(label: "摄入记录", count: preview.intakeRecordCount)

                        if !preview.conflicts.isEmpty {
                            Divider()
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("发现 \(preview.conflicts.count) 个冲突")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text("请选择导入模式")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Import mode picker
                        Picker("导入模式", selection: $selectedImportMode) {
                            Text("合并").tag(ImportMode.merge)
                            Text("替换").tag(ImportMode.replace)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)

                    HStack(spacing: 12) {
                        Button("取消") {
                            viewModel.cancelImport()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)

                        Button("导入") {
                            Task {
                                await viewModel.performImport(mode: selectedImportMode)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                }
            }

            // Import Result Section
            if let result = viewModel.importResult {
                Section("导入结果") {
                    if result.errors.isEmpty {
                        Label {
                            Text("导入成功")
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ResultRow(label: "已导入补剂", count: result.supplementsImported)
                        ResultRow(label: "已导入摄入记录", count: result.intakeRecordsImported)
                    }

                    Button("完成") {
                        viewModel.cancelImport()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                }
            }

            // Error Message Section
            if let errorMessage = viewModel.errorMessage {
                Section {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("数据管理")
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                Task {
                    await viewModel.selectImportFile(url)
                }
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
        .sheet(isPresented: $showingDateRangePicker) {
            DateRangePickerSheet(
                startDate: $exportStartDate,
                endDate: $exportEndDate,
                onConfirm: {
                    Task {
                        await viewModel.exportIntakeRecords(from: exportStartDate, to: exportEndDate)
                        if viewModel.exportedFileURL != nil {
                            showingShareSheet = true
                        }
                    }
                    showingDateRangePicker = false
                }
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            if let fileURL = viewModel.exportedFileURL {
                ShareSheet(items: [fileURL])
            }
        }
    }
}

// MARK: - Supporting Views

/// Row for displaying an export option
struct ExportOptionRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

/// Row for displaying preview information
struct PreviewRow: View {
    let label: String
    let count: Int

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(count) 项")
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

/// Row for displaying import result
struct ResultRow: View {
    let label: String
    let count: Int

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(count)")
                .fontWeight(.medium)
                .foregroundColor(.green)
        }
        .font(.subheadline)
    }
}

/// Sheet for selecting date range
struct DateRangePickerSheet: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
                DatePicker("结束日期", selection: $endDate, in: startDate..., displayedComponents: .date)
            }
            .navigationTitle("选择日期范围")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("导出") {
                        onConfirm()
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Share sheet wrapper for sharing files
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: UserProfile.self, Supplement.self, IntakeRecord.self,
        configurations: config
    )
    let context = ModelContext(container)

    let userRepository = UserRepository(modelContext: context)
    let supplementRepository = SupplementRepository(modelContext: context)
    let intakeRepository = IntakeRecordRepository(modelContext: context)

    let exportService = DataExportService(
        userRepository: userRepository,
        supplementRepository: supplementRepository,
        intakeRepository: intakeRepository
    )
    let importService = DataImportService(
        userRepository: userRepository,
        supplementRepository: supplementRepository,
        intakeRepository: intakeRepository
    )

    NavigationStack {
        DataManagementView(exportService: exportService, importService: importService)
    }
}
