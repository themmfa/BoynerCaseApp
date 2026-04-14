//
//  TestHelpers.swift
//  BoynerCaseAppTests
//
//  Created by F E on 14.04.2026.
//

import Foundation
@testable import BoynerCaseApp

// Helper methods to create test data
enum TestHelpers {

    // Create a sample source
    static func createSource(
        id: String = "test-source",
        name: String = "Test Source",
        description: String = "A test news source",
        url: String = "https://test.com",
        category: String = "general",
        language: String = "en",
        country: String = "us"
    ) -> Source {
        return Source(
            id: id,
            name: name,
            description: description,
            url: url,
            category: category,
            language: language,
            country: country
        )
    }

    // Create a sample article
    static func createArticle(
        title: String = "Test Article",
        url: String = "https://test.com/article",
        publishedAt: String = "2025-01-15T10:30:00Z"
    ) -> Article {
        return Article(
            source: ArticleSource(id: "test", name: "Test"),
            author: "Test Author",
            title: title,
            description: "Test description",
            url: url,
            urlToImage: "https://test.com/image.jpg",
            publishedAt: publishedAt,
            content: "Test content"
        )
    }

    // Create multiple sample sources with different categories/languages
    static func createSampleSources() -> [Source] {
        return [
            createSource(id: "src-1", name: "CNN", category: "general", language: "en"),
            createSource(id: "src-2", name: "TechCrunch", category: "technology", language: "en"),
            createSource(id: "src-3", name: "ESPN", category: "sports", language: "en"),
            createSource(id: "src-4", name: "Le Monde", category: "general", language: "fr"),
            createSource(id: "src-5", name: "Bloomberg", category: "business", language: "en"),
            createSource(id: "src-6", name: "Bild", category: "general", language: "de"),
        ]
    }

    // Create multiple sample articles
    static func createSampleArticles() -> [Article] {
        return [
            createArticle(title: "Article 1", url: "https://test.com/1", publishedAt: "2025-01-15T10:00:00Z"),
            createArticle(title: "Article 2", url: "https://test.com/2", publishedAt: "2025-01-15T12:00:00Z"),
            createArticle(title: "Article 3", url: "https://test.com/3", publishedAt: "2025-01-15T08:00:00Z"),
            createArticle(title: "Article 4", url: "https://test.com/4", publishedAt: "2025-01-15T14:00:00Z"),
            createArticle(title: "Article 5", url: "https://test.com/5", publishedAt: "2025-01-15T06:00:00Z"),
        ]
    }
}
