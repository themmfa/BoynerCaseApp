//
//  ArticlesViewModel.swift
//  BoynerCaseApp
//
//  Created by F E on 14.04.2026.
//

import Foundation
import Combine

@MainActor
class ArticlesViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var currentSliderIndex = 0

    let sourceId: String
    let sourceName: String

    private let networkService: NetworkService
    private let readingListService: ReadingListServiceProtocol
    private var autoRefreshTask: Task<Void, Never>?
    private var sliderTask: Task<Void, Never>?

    // Top 3 articles for slider
    var sliderArticles: [Article] {
        Array(articles.prefix(3))
    }

    // Remaining articles after slider
    var listArticles: [Article] {
        if articles.count > 3 {
            return Array(articles.dropFirst(3))
        }
        return []
    }

    init(
        sourceId: String,
        sourceName: String,
        networkService: NetworkService = NetworkService(),
        readingListService: ReadingListServiceProtocol = ReadingListService()
    ) {
        self.sourceId = sourceId
        self.sourceName = sourceName
        self.networkService = networkService
        self.readingListService = readingListService
    }

    // Fetch articles and sort by most recent first
    func fetchArticles() async {
        isLoading = true
        errorMessage = nil
        showError = false

        do {
            let fetchedArticles = try await networkService.fetchArticles(sourceId: sourceId)

            // Sort by date, most recent first
            articles = fetchedArticles.sorted { first, second in
                guard let date1 = first.publishedDate, let date2 = second.publishedDate else {
                    return false
                }
                return date1 > date2
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // Pull to refresh with error simulation
    func refreshArticles() async {
        isLoading = true
        showError = false

        do {
            let fetchedArticles = try await networkService.fetchArticlesWithErrorSimulation(sourceId: sourceId)

            articles = fetchedArticles.sorted { first, second in
                guard let date1 = first.publishedDate, let date2 = second.publishedDate else {
                    return false
                }
                return date1 > date2
            }
        } catch {
            errorMessage = "Bilgiler alınamadı!"
            showError = true
        }

        isLoading = false
    }

    // MARK: - Reading List Methods

    func isInReadingList(_ article: Article) -> Bool {
        readingListService.isInReadingList(article)
    }

    func toggleReadingList(_ article: Article) {
        if readingListService.isInReadingList(article) {
            readingListService.removeFromReadingList(article)
        } else {
            readingListService.addToReadingList(article)
        }
        // Trigger UI refresh
        objectWillChange.send()
    }

    // MARK: - Auto Refresh (every 60 seconds)

    func startAutoRefresh() {
        stopAutoRefresh()
        autoRefreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 60_000_000_000) // 60 seconds
                guard !Task.isCancelled, let self = self else { break }
                await self.fetchArticles()
            }
        }
    }

    func stopAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil
    }

    // MARK: - Slider Timer (every 5 seconds)

    func startSliderTimer() {
        stopSliderTimer()
        sliderTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                guard !Task.isCancelled, let self = self else { break }
                let count = self.sliderArticles.count
                if count > 0 {
                    self.currentSliderIndex = (self.currentSliderIndex + 1) % count
                }
            }
        }
    }

    func stopSliderTimer() {
        sliderTask?.cancel()
        sliderTask = nil
    }
}
