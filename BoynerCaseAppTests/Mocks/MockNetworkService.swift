//
//  MockNetworkService.swift
//  BoynerCaseAppTests
//
//  Created by F E on 14.04.2026.
//

import Foundation
@testable import BoynerCaseApp

// Mock network service for testing
class MockNetworkService: NetworkServiceProtocol {
    var sourcesToReturn: [Source] = []
    var articlesToReturn: [Article] = []
    var shouldThrowError = false
    var fetchSourcesCalled = false
    var fetchArticlesCalled = false
    var lastSourceId: String?

    func fetchSources() async throws -> [Source] {
        fetchSourcesCalled = true
        if shouldThrowError {
            throw NetworkError.serverError("Mock error")
        }
        return sourcesToReturn
    }

    func fetchArticles(sourceId: String) async throws -> [Article] {
        fetchArticlesCalled = true
        lastSourceId = sourceId
        if shouldThrowError {
            throw NetworkError.serverError("Mock error")
        }
        return articlesToReturn
    }
}
