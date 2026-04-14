//
//  ReadingListServiceTests.swift
//  BoynerCaseAppTests
//
//  Created by F E on 14.04.2026.
//

import XCTest
@testable import BoynerCaseApp

final class ReadingListServiceTests: XCTestCase {
    var service: ReadingListService!
    var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        // Use a separate UserDefaults suite for testing
        testDefaults = UserDefaults(suiteName: "TestReadingList")!
        testDefaults.removePersistentDomain(forName: "TestReadingList")
        service = ReadingListService(userDefaults: testDefaults)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: "TestReadingList")
        service = nil
        testDefaults = nil
        super.tearDown()
    }

    // MARK: - Add Tests

    func testAddToReadingList_AddsArticle() {
        // Given
        let article = TestHelpers.createArticle()

        // When
        service.addToReadingList(article)

        // Then
        let list = service.getReadingList()
        XCTAssertEqual(list.count, 1)
        XCTAssertEqual(list.first?.title, article.title)
    }

    func testAddToReadingList_DoesNotAddDuplicate() {
        // Given
        let article = TestHelpers.createArticle()

        // When
        service.addToReadingList(article)
        service.addToReadingList(article)

        // Then
        let list = service.getReadingList()
        XCTAssertEqual(list.count, 1)
    }

    func testAddMultipleArticles() {
        // Given
        let article1 = TestHelpers.createArticle(title: "Article 1", url: "https://test.com/1")
        let article2 = TestHelpers.createArticle(title: "Article 2", url: "https://test.com/2")

        // When
        service.addToReadingList(article1)
        service.addToReadingList(article2)

        // Then
        let list = service.getReadingList()
        XCTAssertEqual(list.count, 2)
    }

    // MARK: - Remove Tests

    func testRemoveFromReadingList() {
        // Given
        let article = TestHelpers.createArticle()
        service.addToReadingList(article)

        // When
        service.removeFromReadingList(article)

        // Then
        let list = service.getReadingList()
        XCTAssertTrue(list.isEmpty)
    }

    func testRemoveNonExistentArticle_DoesNothing() {
        // Given
        let article1 = TestHelpers.createArticle(title: "Article 1", url: "https://test.com/1")
        let article2 = TestHelpers.createArticle(title: "Article 2", url: "https://test.com/2")
        service.addToReadingList(article1)

        // When
        service.removeFromReadingList(article2)

        // Then
        let list = service.getReadingList()
        XCTAssertEqual(list.count, 1)
    }

    // MARK: - Check Tests

    func testIsInReadingList_ReturnsTrue() {
        // Given
        let article = TestHelpers.createArticle()
        service.addToReadingList(article)

        // When/Then
        XCTAssertTrue(service.isInReadingList(article))
    }

    func testIsInReadingList_ReturnsFalse() {
        // Given
        let article = TestHelpers.createArticle()

        // When/Then
        XCTAssertFalse(service.isInReadingList(article))
    }

    func testGetReadingList_EmptyByDefault() {
        // When
        let list = service.getReadingList()

        // Then
        XCTAssertTrue(list.isEmpty)
    }

    // MARK: - Persistence Test

    func testReadingListPersists() {
        // Given
        let article = TestHelpers.createArticle()
        service.addToReadingList(article)

        // When - create new service with same defaults
        let newService = ReadingListService(userDefaults: testDefaults)

        // Then
        XCTAssertTrue(newService.isInReadingList(article))
        XCTAssertEqual(newService.getReadingList().count, 1)
    }
}
