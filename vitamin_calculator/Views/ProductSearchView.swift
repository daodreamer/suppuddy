//
//  ProductSearchView.swift
//  vitamin_calculator
//
//  Created by Claude Code on 26.01.26.
//

import SwiftUI
import SwiftData

/// View for searching products from the database
struct ProductSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProductSearchViewModel
    @FocusState private var isSearchFieldFocused: Bool

    let onProductSelected: (ScannedProduct) -> Void

    init(
        lookupService: ProductLookupService,
        onProductSelected: @escaping (ScannedProduct) -> Void
    ) {
        self.onProductSelected = onProductSelected
        _viewModel = State(initialValue: ProductSearchViewModel(lookupService: lookupService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar

                // Content
                if viewModel.isLoading && viewModel.searchResults.isEmpty {
                    loadingView
                } else if !viewModel.searchQuery.isEmpty && viewModel.searchResults.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else if viewModel.searchResults.isEmpty {
                    initialStateView
                } else {
                    searchResultsList
                }
            }
            .navigationTitle("Search Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
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

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search for supplements...", text: $viewModel.searchQuery)
                .focused($isSearchFieldFocused)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .onChange(of: viewModel.searchQuery) { _, _ in
                    viewModel.debouncedSearch()
                }
                .onSubmit {
                    Task {
                        await viewModel.search()
                    }
                }

            if !viewModel.searchQuery.isEmpty {
                Button {
                    viewModel.clearResults()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(10)
        .padding()
    }

    // MARK: - Search Results List

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.searchResults, id: \.barcode) { product in
                    ProductSearchResultRow(product: product)
                        .onTapGesture {
                            onProductSelected(product)
                            dismiss()
                        }
                        .onAppear {
                            // Load more when reaching the last item
                            if product.barcode == viewModel.searchResults.last?.barcode {
                                Task {
                                    await viewModel.loadMore()
                                }
                            }
                        }

                    Divider()
                        .padding(.leading, 80)
                }

                // Load more indicator
                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }

                // End message
                if !viewModel.hasMoreResults && !viewModel.searchResults.isEmpty {
                    Text("No more results")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
        }
    }

    // MARK: - State Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Searching...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No Results Found")
                .font(.headline)

            Text("Try searching with different keywords")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var initialStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Search for Supplements")
                .font(.headline)

            Text("Enter a product name or brand to search")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isSearchFieldFocused = true
        }
    }
}

// MARK: - Product Search Result Row

struct ProductSearchResultRow: View {
    let product: ScannedProduct

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Product image
            if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderImage
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
                .frame(width: 60, height: 60)
            } else {
                placeholderImage
            }

            // Product info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.body)
                    .lineLimit(2)

                if let brand = product.brand {
                    Text(brand)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !product.nutrients.isEmpty {
                    Text("\(product.nutrients.count) nutrients")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .contentShape(Rectangle())
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(uiColor: .systemGray5))
            .frame(width: 60, height: 60)
            .overlay(
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            )
    }
}

// MARK: - Preview

#Preview {
    ProductSearchView(
        lookupService: ProductLookupService(
            api: OpenFoodFactsAPI(),
            historyRepository: ScanHistoryRepository(
                modelContext: ModelContext(
                    try! ModelContainer(for: ScanHistory.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
                )
            )
        ),
        onProductSelected: { _ in }
    )
}
