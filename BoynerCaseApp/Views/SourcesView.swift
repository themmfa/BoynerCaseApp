//
//  SourcesView.swift
//  BoynerCaseApp
//
//  Created by F E on 14.04.2026.
//

import SwiftUI

struct SourcesView: View {
    @StateObject private var viewModel = SourcesViewModel()
    @State private var showCategoryFilter = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category filter bar
                categoryFilterSection

                // Sources list
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading sources...")
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 12) {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchSources()
                            }
                        }
                    }
                    .padding()
                    Spacer()
                } else {
                    List(viewModel.filteredSources) { source in
                        NavigationLink(destination: ArticlesView(sourceId: source.id, sourceName: source.name)) {
                            SourceRowView(source: source)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("News Sources")
            .task {
                await viewModel.fetchSources()
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Category Filter Section
    private var categoryFilterSection: some View {
        VStack(spacing: 8) {
            // Toggle button
            Button(action: {
                withAnimation {
                    showCategoryFilter.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text("Filter by Category")
                    Spacer()
                    if !viewModel.selectedCategories.isEmpty {
                        Text("\(viewModel.selectedCategories.count) selected")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Image(systemName: showCategoryFilter ? "chevron.up" : "chevron.down")
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }

            // Category chips
            if showCategoryFilter {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            CategoryChipView(
                                title: category.capitalized,
                                isSelected: viewModel.selectedCategories.contains(category)
                            ) {
                                viewModel.toggleCategory(category)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }

            Divider()
        }
    }
}

// MARK: - Source Row View
struct SourceRowView: View {
    let source: Source

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(source.name)
                .font(.headline)

            Text(source.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Text(source.category.capitalized)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Category Chip View
struct CategoryChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}
