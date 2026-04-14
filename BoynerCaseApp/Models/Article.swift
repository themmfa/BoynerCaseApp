//
//  Article.swift
//  BoynerCaseApp
//
//  Created by F E on 14.04.2026.
//

import Foundation

// MARK: - Articles API Response
struct ArticlesResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

// MARK: - Article Model
struct Article: Codable, Identifiable, Equatable {
    let source: ArticleSource
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?

    // Computed id from url since articles don't have a unique id
    var id: String { url }

    // Parse publishedAt string to Date
    var publishedDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: publishedAt) {
            return date
        }
        // Fallback without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: publishedAt)
    }

    // Formatted date string for display
    var formattedDate: String {
        guard let date = publishedDate else { return publishedAt }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.url == rhs.url
    }
}

// MARK: - Article Source (nested in article response)
struct ArticleSource: Codable, Hashable {
    let id: String?
    let name: String
}
