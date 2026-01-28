//
//  ScanHistoryView.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import SwiftUI
import SwiftData

/// View for displaying scan history
struct ScanHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ScanHistoryViewModel
    @State private var showingClearConfirmation = false

    let onHistorySelected: (ScanHistory) -> Void

    init(
        lookupService: ProductLookupService,
        onHistorySelected: @escaping (ScanHistory) -> Void
    ) {
        self.onHistorySelected = onHistorySelected
        _viewModel = State(initialValue: ScanHistoryViewModel(lookupService: lookupService))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.scanHistory.isEmpty {
                    loadingView
                } else if viewModel.scanHistory.isEmpty {
                    emptyStateView
                } else {
                    historyList
                }
            }
            .navigationTitle("Scan History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }

                if !viewModel.scanHistory.isEmpty {
                    ToolbarItem(placement: .destructiveAction) {
                        Button(role: .destructive) {
                            showingClearConfirmation = true
                        } label: {
                            Text("Clear All")
                        }
                    }
                }
            }
            .task {
                await viewModel.loadHistory()
            }
            .alert("Clear All History?", isPresented: $showingClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    Task {
                        await viewModel.clearAllHistory()
                    }
                }
            } message: {
                Text("This will delete all scan history records. This action cannot be undone.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }

    // MARK: - History List

    private var historyList: some View {
        List {
            ForEach(viewModel.scanHistory, id: \.barcode) { item in
                ScanHistoryRow(item: item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if item.wasSuccessful {
                            onHistorySelected(item)
                            dismiss()
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteHistory(item)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.loadHistory()
        }
    }

    // MARK: - State Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading history...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Scan History")
                .font(.headline)

            Text("Your scanned products will appear here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Scan History Row

struct ScanHistoryRow: View {
    let item: ScanHistory

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Status icon
            statusIcon

            // Product info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.productName)
                    .font(.body)
                    .lineLimit(2)

                if let brand = item.brand {
                    Text(brand)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    // Barcode
                    HStack(spacing: 4) {
                        Image(systemName: "barcode")
                            .font(.caption2)
                        Text(item.barcode)
                            .font(.caption2)
                            .monospaced()
                    }

                    Text("•")
                        .font(.caption2)

                    // Timestamp
                    Text(item.scannedAt, style: .relative)
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Chevron (only for successful scans)
            if item.wasSuccessful {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    private var statusIcon: some View {
        Group {
            if item.wasSuccessful {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScanHistoryView(
        lookupService: ProductLookupService(
            api: OpenFoodFactsAPI(),
            historyRepository: ScanHistoryRepository(
                modelContext: ModelContext(
                    try! ModelContainer(for: ScanHistory.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
                )
            )
        ),
        onHistorySelected: { _ in }
    )
}
