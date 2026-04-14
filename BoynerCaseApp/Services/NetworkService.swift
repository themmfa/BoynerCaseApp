//
//  NetworkService.swift
//  BoynerCaseApp
//
//  Created by F E on 14.04.2026.
//

import Foundation

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case missingAPIKey
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let message):
            return message
        case .missingAPIKey:
            return "API key is missing. Check Secrets.xcconfig."
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func fetchSources() async throws -> [Source]
    func fetchArticles(sourceId: String) async throws -> [Article]
}

// MARK: - Network Service
class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://newsapi.org"
    private let session: URLSession
    private let apiKey: String

    // Request counter for error simulation (pull to refresh)
    private var requestCount = 0

    init(session: URLSession = .shared, apiKey: String? = nil) {
        self.session = session

        // Read API key: first from init param, then from Info.plist (populated by xcconfig)
        if let key = apiKey {
            self.apiKey = key
        } else if let key = Bundle.main.object(forInfoDictionaryKey: "NEWS_API_KEY") as? String,
                  !key.isEmpty,
                  key != "YOUR_API_KEY_HERE" {
            self.apiKey = key
        } else {
            self.apiKey = ""
        }
    }

    // Fetch all news sources
    func fetchSources() async throws -> [Source] {
        guard !apiKey.isEmpty else { throw NetworkError.missingAPIKey }

        guard let url = URL(string: "\(baseURL)/v2/sources?language=en&apiKey=\(apiKey)") else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Server returned an error")
        }

        do {
            let sourcesResponse = try JSONDecoder().decode(SourcesResponse.self, from: data)
            return sourcesResponse.sources
        } catch {
            throw NetworkError.decodingError
        }
    }

    // Fetch articles for a specific source
    func fetchArticles(sourceId: String) async throws -> [Article] {
        guard !apiKey.isEmpty else { throw NetworkError.missingAPIKey }

        guard let url = URL(string: "\(baseURL)/v2/top-headlines?sources=\(sourceId)&apiKey=\(apiKey)") else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Server returned an error")
        }

        do {
            let articlesResponse = try JSONDecoder().decode(ArticlesResponse.self, from: data)
            return articlesResponse.articles
        } catch {
            throw NetworkError.decodingError
        }
    }

    // Fetch articles with error simulation for pull to refresh
    // Every 3rd request simulates an error
    func fetchArticlesWithErrorSimulation(sourceId: String) async throws -> [Article] {
        requestCount += 1

        if requestCount % 3 == 0 {
            throw NetworkError.serverError("Bilgiler alınamadı!")
        }

        return try await fetchArticles(sourceId: sourceId)
    }
}
