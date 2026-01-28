//
//  SupplementListView.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import SwiftUI
import SwiftData

/// Main list view for displaying and managing supplements
struct SupplementListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SupplementListViewModel?
    @State private var showingAddForm = false
    @State private var selectedSupplement: Supplement?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    supplementList(viewModel: viewModel)
                } else {
                    ProgressView("Loading...")
                }
            }
            .navigationTitle("Supplements")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddForm = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(AccessibilityHelper.supplementAddButton)
                    .accessibilityHint("点击添加新的补剂")
                }
                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        sortMenu
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .accessibilityLabel(AccessibilityHelper.supplementSortButton)
                    .accessibilityHint("选择补剂排序方式")
                }
            }
            .sheet(isPresented: $showingAddForm) {
                if let viewModel = viewModel {
                    SupplementFormView(repository: viewModel.repository) {
                        Task { await viewModel.loadSupplements() }
                    }
                }
            }
            .sheet(item: $selectedSupplement) { supplement in
                if let viewModel = viewModel {
                    SupplementFormView(
                        repository: viewModel.repository,
                        supplement: supplement
                    ) {
                        Task { await viewModel.loadSupplements() }
                    }
                }
            }
        }
        .task {
            if viewModel == nil {
                let repository = SupplementRepository(modelContext: modelContext)
                viewModel = SupplementListViewModel(repository: repository)
                await viewModel?.loadSupplements()
            }
        }
    }

    @ViewBuilder
    private func supplementList(viewModel: SupplementListViewModel) -> some View {
        List {
            if viewModel.supplements.isEmpty {
                ContentUnavailableView(
                    "No Supplements",
                    systemImage: "pills",
                    description: Text("Add your first supplement to get started")
                )
            } else {
                ForEach(viewModel.supplements, id: \.persistentModelID) { supplement in
                    NavigationLink(destination: SupplementDetailView(supplement: supplement, repository: viewModel.repository)) {
                        SupplementRowView(supplement: supplement)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task { await viewModel.delete(supplement) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .accessibilityLabel(AccessibilityHelper.supplementDeleteAction)
                        .accessibilityHint("删除补剂 \(supplement.name)")
                        Button {
                            selectedSupplement = supplement
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                        .accessibilityLabel(AccessibilityHelper.supplementEditAction)
                        .accessibilityHint("编辑补剂 \(supplement.name)")
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            Task { await viewModel.toggleActive(supplement) }
                        } label: {
                            Label(
                                supplement.isActive ? "Deactivate" : "Activate",
                                systemImage: supplement.isActive ? "pause.circle" : "play.circle"
                            )
                        }
                        .tint(supplement.isActive ? .orange : .green)
                        .accessibilityLabel(supplement.isActive ? AccessibilityHelper.supplementDeactivateAction : AccessibilityHelper.supplementActivateAction)
                        .accessibilityHint(supplement.isActive ? "暂停使用补剂 \(supplement.name)" : "恢复使用补剂 \(supplement.name)")
                    }
                }
            }
        }
        .searchable(text: Binding(
            get: { viewModel.searchQuery },
            set: { viewModel.searchQuery = $0 }
        ))
        .onChange(of: viewModel.searchQuery) { _, _ in
            Task { await viewModel.search() }
        }
        .refreshable {
            await viewModel.loadSupplements()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var sortMenu: some View {
        Group {
            Button {
                viewModel?.sortOption = .name
                Task { await viewModel?.loadSupplements() }
            } label: {
                Label("Sort by Name", systemImage: viewModel?.sortOption == .name ? "checkmark" : "")
            }
            Button {
                viewModel?.sortOption = .createdAt
                Task { await viewModel?.loadSupplements() }
            } label: {
                Label("Sort by Date Added", systemImage: viewModel?.sortOption == .createdAt ? "checkmark" : "")
            }
            Divider()
            Button {
                viewModel?.sortAscending.toggle()
                Task { await viewModel?.loadSupplements() }
            } label: {
                Label(
                    viewModel?.sortAscending == true ? "Descending" : "Ascending",
                    systemImage: viewModel?.sortAscending == true ? "arrow.down" : "arrow.up"
                )
            }
        }
    }
}

/// Row view for a single supplement in the list
struct SupplementRowView: View {
    let supplement: Supplement

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(supplement.name)
                    .font(.headline)
                    .foregroundColor(supplement.isActive ? .primary : .secondary)

                if let brand = supplement.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text("\(supplement.servingSize) • \(supplement.servingsPerDay)x/day")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !supplement.isActive {
                Image(systemName: "moon.zzz.fill")
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }

            Text("\(supplement.nutrients.count)")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.2))
                .clipShape(Capsule())
                .accessibilityHidden(true)
        }
        .opacity(supplement.isActive ? 1.0 : 0.6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AccessibilityHelper.supplementRowLabel(
            name: supplement.name,
            brand: supplement.brand,
            servingSize: supplement.servingSize,
            servingsPerDay: supplement.servingsPerDay,
            nutrientCount: supplement.nutrients.count,
            isActive: supplement.isActive
        ))
    }
}
