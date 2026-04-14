//
//  ArticleModelTests.swift
//  BoynerCaseAppTests
//
//  Created by F E on 14.04.2026.
//

import XCTest
@testable import BoynerCaseApp

final class ArticleModelTests: XCTestCase {

    // MARK: - Date Parsing Tests

    func testPublishedDate_ValidISO8601() {
        // Given
        let article = TestHelpers.createArticle(publishedAt: "2025-01-15T10:30:00Z")

        // When
        let date = article.publishedDate

        // Then
        XCTAssertNotNil(date)
    }

    func testPublishedDate_WithFractionalSeconds() {
        // Given
        let article = TestHelpers.createArticle(publishedAt: "2025-01-15T10:30:00.000Z")

        // When
        let date = article.publishedDate

        // Then
        XCTAssertNotNil(date)
    }

    func testFormattedDate_ReturnsFormattedString() {
        // Given
        let article = TestHelpers.createArticle(publishedAt: "2025-01-15T10:30:00Z")

        // When
        let formatted = article.formattedDate

        // Then - should not be the raw string
        XCTAssertFalse(formatted.isEmpty)
        XCTAssertNotEqual(formatted, "2025-01-15T10:30:00Z")
    }

    // MARK: - ID Tests

    func testArticleId_UsesURL() {
        // Given
        let article = TestHelpers.createArticle(url: "https://test.com/unique-article")

        // Then
        XCTAssertEqual(article.id, "https://test.com/unique-article")
    }

    // MARK: - Equality Tests

    func testArticleEquality_SameURL() {
        // Given
        let article1 = TestHelpers.createArticle(title: "Title 1", url: "https://test.com/same")
        let article2 = TestHelpers.createArticle(title: "Title 2", url: "https://test.com/same")

        // Then
        XCTAssertEqual(article1, article2)
    }

    func testArticleEquality_DifferentURL() {
        // Given
        let article1 = TestHelpers.createArticle(url: "https://test.com/1")
        let article2 = TestHelpers.createArticle(url: "https://test.com/2")

        // Then
        XCTAssertNotEqual(article1, article2)
    }

    // MARK: - Decoding Tests

    func testSourceDecoding() {
        // Given
        let json = """
        {
            "status": "ok",
            "sources": [
                {
                    "id": "abc-news",
                    "name": "ABC News",
                    "description": "Test desc",
                    "url": "https://abcnews.go.com",
                    "category": "general",
                    "language": "en",
                    "country": "us"
                }
            ]
        }
        """.data(using: .utf8)!

        // When
        let response = try? JSONDecoder().decode(SourcesResponse.self, from: json)

        // Then
        XCTAssertNotNil(response)
        XCTAssertEqual(response?.sources.count, 1)
        XCTAssertEqual(response?.sources.first?.id, "abc-news")
    }

    func testArticleDecoding() {
        // Given
        let json = """
        {
            "status": "ok",
            "totalResults": 1,
            "articles": [
                {
                    "source": {"id": "test", "name": "Test"},
                    "author": "Author",
                    "title": "Test Title",
                    "description": "Desc",
                    "url": "https://test.com/article",
                    "urlToImage": "https://test.com/img.jpg",
                    "publishedAt": "2025-01-15T10:30:00Z",
                    "content": "Content"
                }
            ]
        }
        """.data(using: .utf8)!

        // When
        let response = try? JSONDecoder().decode(ArticlesResponse.self, from: json)

        // Then
        XCTAssertNotNil(response)
        XCTAssertEqual(response?.articles.count, 1)
        XCTAssertEqual(response?.articles.first?.title, "Test Title")
    }
}
