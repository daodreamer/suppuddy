//
//  SupplementDetailView.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import SwiftUI
import SwiftData

/// Detail view for displaying supplement information and nutrient breakdown
struct SupplementDetailView: View {
    let supplement: Supplement
    let repository: SupplementRepository
    @State private var viewModel: SupplementDetailViewModel?
    @State private var showingEditForm = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            if let viewModel = viewModel {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection(viewModel: viewModel)
                    nutrientsSection(viewModel: viewModel)
                    if let notes = supplement.notes, !notes.isEmpty {
                        notesSection(notes: notes)
                    }
                    infoSection
                }
                .padding()
            } else {
                ProgressView()
            }
        }
        .navigationTitle(supplement.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEditForm = true }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    Task {
                        await viewModel?.toggleActive(using: repository)
                    }
                } label: {
                    Image(systemName: supplement.isActive ? "pause.circle" : "play.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditForm) {
            SupplementFormView(repository: repository, supplement: supplement) {
                // Refresh after edit
            }
        }
        .onAppear {
            viewModel = SupplementDetailViewModel(supplement: supplement)
        }
    }

    private func headerSection(viewModel: SupplementDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    if let brand = supplement.brand {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Text(supplement.servingSize)
                        .font(.headline)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(supplement.servingsPerDay)x")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("per day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if !supplement.isActive {
                Label("Inactive", systemImage: "moon.zzz.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func nutrientsSection(viewModel: SupplementDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutrients")
                .font(.headline)

            if supplement.nutrients.isEmpty {
                Text("No nutrients added")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(supplement.nutrients, id: \.type) { nutrient in
                    NutrientRowView(
                        nutrient: nutrient,
                        dailyAmount: viewModel.supplement.totalDailyAmount(for: nutrient.type),
                        percentage: viewModel.percentageOfRecommendation(for: nutrient.type, userType: .male),
                        status: viewModel.nutrientStatus(for: nutrient.type, userType: .male)
                    )
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func notesSection(notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            Text(notes)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Information")
                .font(.headline)
            HStack {
                Text("Added")
                Spacer()
                Text(supplement.createdAt, style: .date)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("Last updated")
                Spacer()
                Text(supplement.updatedAt, style: .date)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Row view for a single nutrient with daily amount and status
struct NutrientRowView: View {
    let nutrient: Nutrient
    let dailyAmount: Double
    let percentage: Double
    let status: NutrientStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(nutrient.type.localizedName)
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.1f %@", dailyAmount, nutrient.type.unit))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            HStack {
                ProgressView(value: min(percentage / 100, 1.0))
                    .tint(statusColor)

                Text(String(format: "%.0f%%", percentage))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 45, alignment: .trailing)
            }
        }
        .padding(.vertical, 4)
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
}
