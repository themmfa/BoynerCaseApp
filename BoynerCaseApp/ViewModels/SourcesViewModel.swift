//
//  SourcesViewModel.swift
//  BoynerCaseApp
//
//  Created by F E on 14.04.2026.
//

import Foundation
import Combine

class SourcesViewModel: ObservableObject {
    @Published var sources: [Source] = []
    @Published var filteredSources: [Source] = []
    @Published var categories: [String] = []
    @Published var selectedCategories: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    // Fetch sources from API (language=en is handled by the API request)
    @MainActor
    func fetchSources() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedSources = try await networkService.fetchSources()

            // API already returns only English sources via language=en param
            sources = fetchedSources

            // Extract unique categories from sources for client-side filtering
            let categorySet = Set(sources.map { $0.category })
            categories = Array(categorySet).sorted()

            // Apply current category filter
            applyFilter()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // Toggle category selection for filtering
    func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        applyFilter()
    }

    // Apply category filter to sources list
    func applyFilter() {
        if selectedCategories.isEmpty {
            // No filter selected, show all
            filteredSources = sources
        } else {
            filteredSources = sources.filter { selectedCategories.contains($0.category) }
        }
    }
}
