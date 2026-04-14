//
//  MockReadingListService.swift
//  BoynerCaseAppTests
//
//  Created by F E on 14.04.2026.
//

import Foundation
@testable import BoynerCaseApp

// Mock reading list service for testing
class MockReadingListService: ReadingListServiceProtocol {
    var readingList: [Article] = []

    func getReadingList() -> [Article] {
        return readingList
    }

    func addToReadingList(_ article: Article) {
        guard !readingList.contains(where: { $0.url == article.url }) else { return }
        readingList.append(article)
    }

    func removeFromReadingList(_ article: Article) {
        readingList.removeAll { $0.url == article.url }
    }

    func isInReadingList(_ article: Article) -> Bool {
        return readingList.contains(where: { $0.url == article.url })
    }
}
