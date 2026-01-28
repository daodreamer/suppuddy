//
//  SupplementFormView.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import SwiftUI
import SwiftData

/// Form view for creating or editing a supplement
struct SupplementFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SupplementFormViewModel
    @State private var showingNutrientPicker = false
    @State private var selectedNutrientType: NutrientType?
    @State private var nutrientAmount: String = ""

    // Quick add states
    @State private var showingScanner = false
    @State private var showingSearch = false
    @State private var showingProductDetail = false
    @State private var selectedScannedProduct: ScannedProduct?

    private let repository: SupplementRepository
    private let onSave: () -> Void

    // Services for scanning and search
    private let scannerService: BarcodeScannerService
    private let lookupService: ProductLookupService

    init(
        repository: SupplementRepository,
        supplement: Supplement? = nil,
        scannerService: BarcodeScannerService = BarcodeScannerService(),
        lookupService: ProductLookupService? = nil,
        modelContext: ModelContext? = nil,
        onSave: @escaping () -> Void
    ) {
        self.repository = repository
        self.onSave = onSave
        self.scannerService = scannerService

        // Create lookup service if not provided
        if let lookupService = lookupService {
            self.lookupService = lookupService
        } else if let context = modelContext {
            self.lookupService = ProductLookupService(
                api: OpenFoodFactsAPI(),
                historyRepository: ScanHistoryRepository(modelContext: context)
            )
        } else {
            // Fallback - will be initialized in onAppear
            self.lookupService = ProductLookupService(
                api: OpenFoodFactsAPI(),
                historyRepository: ScanHistoryRepository(
                    modelContext: ModelContext(
                        try! ModelContainer(for: ScanHistory.self)
                    )
                )
            )
        }

        if let supplement = supplement {
            _viewModel = State(initialValue: SupplementFormViewModel(supplement: supplement))
        } else {
            _viewModel = State(initialValue: SupplementFormViewModel())
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // Quick add section (only for new supplements)
                if !viewModel.isEditing {
                    quickAddSection
                }

                basicInfoSection
                servingSection
                nutrientsSection
                notesSection
                activeSection
            }
            .navigationTitle(viewModel.isEditing ? "Edit Supplement" : "New Supplement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if await viewModel.save(using: repository) {
                                onSave()
                                dismiss()
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNutrientPicker) {
                NutrientPickerView(
                    selectedType: $selectedNutrientType,
                    amount: $nutrientAmount,
                    existingNutrients: viewModel.nutrients.map { $0.type }
                ) { type, amount in
                    viewModel.addNutrient(type: type, amount: amount)
                    showingNutrientPicker = false
                    selectedNutrientType = nil
                    nutrientAmount = ""
                }
            }
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView(
                    scannerService: scannerService,
                    lookupService: lookupService,
                    onProductScanned: { product in
                        selectedScannedProduct = product
                        showingProductDetail = true
                    }
                )
            }
            .sheet(isPresented: $showingSearch) {
                ProductSearchView(
                    lookupService: lookupService,
                    onProductSelected: { product in
                        selectedScannedProduct = product
                        showingProductDetail = true
                    }
                )
            }
            .sheet(isPresented: $showingProductDetail) {
                if let product = selectedScannedProduct {
                    ScannedProductDetailView(
                        product: product,
                        onConfirm: { product, servingsPerDay in
                            fillFormFromProduct(product, servingsPerDay: servingsPerDay)
                        }
                    )
                }
            }
            .alert("Validation Error", isPresented: .constant(!viewModel.validationErrors.isEmpty)) {
                Button("OK") { }
            } message: {
                Text(validationErrorMessage)
            }
        }
    }

    // MARK: - Quick Add Section

    private var quickAddSection: some View {
        Section {
            Button {
                showingScanner = true
            } label: {
                Label("Scan Barcode", systemImage: "barcode.viewfinder")
            }

            Button {
                showingSearch = true
            } label: {
                Label("Search Products", systemImage: "magnifyingglass")
            }
        } header: {
            Text("Quick Add")
        } footer: {
            Text("Scan a product barcode or search our database to quickly add supplement information")
        }
    }

    private var basicInfoSection: some View {
        Section("Basic Information") {
            TextField("Name", text: $viewModel.name)
            TextField("Brand (optional)", text: $viewModel.brand)
        }
    }

    private var servingSection: some View {
        Section("Serving") {
            TextField("Serving Size (e.g., 1 tablet)", text: $viewModel.servingSize)
            Stepper("Servings per day: \(viewModel.servingsPerDay)", value: $viewModel.servingsPerDay, in: 1...10)
        }
    }

    private var nutrientsSection: some View {
        Section {
            if viewModel.nutrients.isEmpty {
                Text("No nutrients added")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(Array(viewModel.nutrients.enumerated()), id: \.element.type) { index, nutrient in
                    HStack {
                        Text(nutrient.type.localizedName)
                        Spacer()
                        Text(String(format: "%.1f %@", nutrient.amount, nutrient.type.unit))
                            .foregroundColor(.secondary)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.removeNutrient(at: index)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }

            Button {
                showingNutrientPicker = true
            } label: {
                Label("Add Nutrient", systemImage: "plus.circle")
            }
        } header: {
            Text("Nutrients (per serving)")
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            TextEditor(text: $viewModel.notes)
                .frame(minHeight: 80)
        }
    }

    private var activeSection: some View {
        Section {
            Toggle("Currently Taking", isOn: $viewModel.isActive)
        }
    }

    private var validationErrorMessage: String {
        viewModel.validationErrors.map { error in
            switch error {
            case .emptyName:
                return "Name is required"
            case .emptyServingSize:
                return "Serving size is required"
            case .invalidServingsPerDay:
                return "Servings per day must be at least 1"
            }
        }.joined(separator: "\n")
    }

    // MARK: - Helper Methods

    /// Fills the form with data from a scanned product
    private func fillFormFromProduct(_ product: ScannedProduct, servingsPerDay: Int) {
        // Fill basic info
        viewModel.name = product.name
        if let brand = product.brand {
            viewModel.brand = brand
        }
        if let servingSize = product.servingSize {
            viewModel.servingSize = servingSize
        }
        viewModel.servingsPerDay = servingsPerDay

        // Add nutrients that can be mapped
        let mappedNutrients = product.toNutrients()
        for nutrient in mappedNutrients {
            viewModel.addNutrient(type: nutrient.type, amount: nutrient.amount)
        }
    }
}

/// Picker view for selecting a nutrient type and entering amount
struct NutrientPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedType: NutrientType?
    @Binding var amount: String
    let existingNutrients: [NutrientType]
    let onAdd: (NutrientType, Double) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Select Nutrient") {
                    Picker("Nutrient", selection: $selectedType) {
                        Text("Select...").tag(nil as NutrientType?)
                        ForEach(availableNutrients, id: \.self) { type in
                            Text(type.localizedName).tag(type as NutrientType?)
                        }
                    }
                }

                if let selectedType = selectedType {
                    Section("Amount per serving") {
                        HStack {
                            TextField("Amount", text: $amount)
                                .keyboardType(.decimalPad)
                            Text(selectedType.unit)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Add Nutrient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let type = selectedType, let amountValue = Double(amount) {
                            onAdd(type, amountValue)
                        }
                    }
                    .disabled(selectedType == nil || Double(amount) == nil)
                }
            }
        }
    }

    private var availableNutrients: [NutrientType] {
        NutrientType.allCases.filter { !existingNutrients.contains($0) }
    }
}
