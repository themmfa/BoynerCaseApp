//
//  ReadingListService.swift
//  BoynerCaseApp
//
//  Created by F E on 14.04.2026.
//

import Foundation

// MARK: - Reading List Protocol
protocol ReadingListServiceProtocol {
    func getReadingList() -> [Article]
    func addToReadingList(_ article: Article)
    func removeFromReadingList(_ article: Article)
    func isInReadingList(_ article: Article) -> Bool
}

// MARK: - Reading List Service
// Stores reading list articles locally using UserDefaults
class ReadingListService: ReadingListServiceProtocol {
    private let userDefaults: UserDefaults
    private let readingListKey = "reading_list"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // Get all articles in reading list
    func getReadingList() -> [Article] {
        guard let data = userDefaults.data(forKey: readingListKey) else {
            return []
        }

        do {
            let articles = try JSONDecoder().decode([Article].self, from: data)
            return articles
        } catch {
            print("Error decoding reading list: \(error)")
            return []
        }
    }

    // Add article to reading list
    func addToReadingList(_ article: Article) {
        var list = getReadingList()

        // Don't add duplicates
        guard !list.contains(where: { $0.url == article.url }) else { return }

        list.append(article)
        saveReadingList(list)
    }

    // Remove article from reading list
    func removeFromReadingList(_ article: Article) {
        var list = getReadingList()
        list.removeAll { $0.url == article.url }
        saveReadingList(list)
    }

    // Check if article is in reading list
    func isInReadingList(_ article: Article) -> Bool {
        let list = getReadingList()
        return list.contains(where: { $0.url == article.url })
    }

    // Save reading list to UserDefaults
    private func saveReadingList(_ list: [Article]) {
        do {
            let data = try JSONEncoder().encode(list)
            userDefaults.set(data, forKey: readingListKey)
        } catch {
            print("Error saving reading list: \(error)")
        }
    }
}
