//
//  ScannedProductDetailView.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import SwiftUI

/// View for displaying scanned product details and confirming addition
struct ScannedProductDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let product: ScannedProduct
    let onConfirm: (ScannedProduct, Int) -> Void

    @State private var servingsPerDay: Int = 1

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    productHeader
                    nutrientsList
                    servingsSelector
                }
                .padding()
            }
            .navigationTitle("Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onConfirm(product, servingsPerDay)
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Product Header

    private var productHeader: some View {
        VStack(spacing: 12) {
            // Product image
            if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderImage
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
                .frame(maxHeight: 200)
            } else {
                placeholderImage
            }

            // Product name
            VStack(spacing: 4) {
                Text(product.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                if let brand = product.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Barcode
            HStack {
                Image(systemName: "barcode")
                    .font(.caption)
                Text(product.barcode)
                    .font(.caption)
                    .monospaced()
            }
            .foregroundStyle(.secondary)

            // Serving size
            if let servingSize = product.servingSize {
                HStack {
                    Image(systemName: "scalemass")
                        .font(.caption)
                    Text("Serving: \(servingSize)")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(uiColor: .tertiarySystemBackground))
            .frame(height: 200)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 50))
                    .foregroundStyle(.secondary)
            )
    }

    // MARK: - Nutrients List

    private var nutrientsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutrients (per serving)")
                .font(.headline)

            if product.nutrients.isEmpty {
                Text("No nutrient information available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(product.nutrients.enumerated()), id: \.element.name) { index, nutrient in
                        NutrientRow(nutrient: nutrient)

                        if index < product.nutrients.count - 1 {
                            Divider()
                                .padding(.leading)
                        }
                    }
                }
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
            }

            // Mapped nutrients info
            let mappedNutrients = product.toNutrients()
            if !mappedNutrients.isEmpty && mappedNutrients.count < product.nutrients.count {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue)
                    Text("\(mappedNutrients.count) of \(product.nutrients.count) nutrients can be tracked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Servings Selector

    private var servingsSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Intake")
                .font(.headline)

            HStack {
                Text("Servings per day")
                    .font(.body)

                Spacer()

                HStack(spacing: 16) {
                    Button {
                        if servingsPerDay > 1 {
                            servingsPerDay -= 1
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(servingsPerDay > 1 ? Color.blue : Color.gray)
                    }
                    .disabled(servingsPerDay <= 1)

                    Text("\(servingsPerDay)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(minWidth: 30)

                    Button {
                        if servingsPerDay < 10 {
                            servingsPerDay += 1
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(servingsPerDay < 10 ? Color.blue : Color.gray)
                    }
                    .disabled(servingsPerDay >= 10)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)

            Text("This will be added to your daily supplement list")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Nutrient Row

struct NutrientRow: View {
    let nutrient: ScannedNutrient

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(nutrient.name.capitalized)
                    .font(.body)

                // Show if it can be mapped
                if let mapped = nutrient.toNutrient() {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                        Text(mapped.type.localizedName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Text(String(format: "%.1f %@", nutrient.amount, nutrient.unit))
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview

#Preview {
    ScannedProductDetailView(
        product: ScannedProduct(
            barcode: "1234567890123",
            name: "Multivitamin Complex",
            brand: "Health Plus",
            imageUrl: nil,
            servingSize: "1 tablet",
            nutrients: [
                ScannedNutrient(name: "vitamin-c", amount: 100, unit: "mg"),
                ScannedNutrient(name: "vitamin-d", amount: 20, unit: "μg"),
                ScannedNutrient(name: "calcium", amount: 500, unit: "mg")
            ]
        ),
        onConfirm: { _, _ in }
    )
}
