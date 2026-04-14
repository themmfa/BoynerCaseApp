//
//  SourcesViewModelTests.swift
//  BoynerCaseAppTests
//
//  Created by F E on 14.04.2026.
//

import XCTest
@testable import BoynerCaseApp

@MainActor
final class SourcesViewModelTests: XCTestCase {
    var viewModel: SourcesViewModel!
    var mockNetworkService: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = SourcesViewModel(networkService: mockNetworkService)
    }

    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }

    // MARK: - Fetch Sources Tests

    func testFetchSources_StoresAllReturnedSources() async {
        // Given - API already returns only English sources via language=en param
        let englishSources = [
            TestHelpers.createSource(id: "1", name: "CNN", category: "general"),
            TestHelpers.createSource(id: "2", name: "TechCrunch", category: "technology"),
            TestHelpers.createSource(id: "3", name: "ESPN", category: "sports"),
            TestHelpers.createSource(id: "4", name: "Bloomberg", category: "business"),
        ]
        mockNetworkService.sourcesToReturn = englishSources

        // When
        await viewModel.fetchSources()

        // Then - all sources from API should be stored (language filtering is done server-side)
        XCTAssertEqual(viewModel.sources.count, 4)
    }

    func testFetchSources_CategoriesAreExtracted() async {
        // Given
        let sources = [
            TestHelpers.createSource(id: "1", category: "general"),
            TestHelpers.createSource(id: "2", category: "technology"),
            TestHelpers.createSource(id: "3", category: "sports"),
            TestHelpers.createSource(id: "4", category: "business"),
        ]
        mockNetworkService.sourcesToReturn = sources

        // When
        await viewModel.fetchSources()

        // Then
        XCTAssertEqual(viewModel.categories.count, 4)
        XCTAssertTrue(viewModel.categories.contains("general"))
        XCTAssertTrue(viewModel.categories.contains("technology"))
        XCTAssertTrue(viewModel.categories.contains("sports"))
        XCTAssertTrue(viewModel.categories.contains("business"))
    }

    func testFetchSources_CategoriesAreSorted() async {
        // Given
        let sources = [
            TestHelpers.createSource(id: "1", category: "technology"),
            TestHelpers.createSource(id: "2", category: "general"),
            TestHelpers.createSource(id: "3", category: "sports"),
        ]
        mockNetworkService.sourcesToReturn = sources

        // When
        await viewModel.fetchSources()

        // Then
        XCTAssertEqual(viewModel.categories, viewModel.categories.sorted())
    }

    func testFetchSources_ErrorSetsErrorMessage() async {
        // Given
        mockNetworkService.shouldThrowError = true

        // When
        await viewModel.fetchSources()

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.sources.isEmpty)
    }

    func testFetchSources_LoadingStateChanges() async {
        // Given
        mockNetworkService.sourcesToReturn = []

        // When
        await viewModel.fetchSources()

        // Then - after completion, loading should be false
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Category Filter Tests

    func testToggleCategory_AddsCategory() {
        // Given
        viewModel.sources = [
            TestHelpers.createSource(id: "1", category: "general"),
            TestHelpers.createSource(id: "2", category: "sports"),
        ]
        viewModel.categories = ["general", "sports"]

        // When
        viewModel.toggleCategory("general")

        // Then
        XCTAssertTrue(viewModel.selectedCategories.contains("general"))
    }

    func testToggleCategory_RemovesCategoryOnSecondToggle() {
        // Given
        viewModel.sources = [TestHelpers.createSource(id: "1", category: "general")]
        viewModel.categories = ["general"]

        // When
        viewModel.toggleCategory("general")
        viewModel.toggleCategory("general")

        // Then
        XCTAssertFalse(viewModel.selectedCategories.contains("general"))
    }

    func testApplyFilter_NoSelectionShowsAll() {
        // Given
        let sources = [
            TestHelpers.createSource(id: "1", category: "general"),
            TestHelpers.createSource(id: "2", category: "sports"),
        ]
        viewModel.sources = sources

        // When
        viewModel.applyFilter()

        // Then
        XCTAssertEqual(viewModel.filteredSources.count, 2)
    }

    func testApplyFilter_WithSelectionFiltersCorrectly() {
        // Given
        viewModel.sources = [
            TestHelpers.createSource(id: "1", category: "general"),
            TestHelpers.createSource(id: "2", category: "sports"),
            TestHelpers.createSource(id: "3", category: "technology"),
        ]

        // When - select only sports
        viewModel.toggleCategory("sports")

        // Then
        XCTAssertEqual(viewModel.filteredSources.count, 1)
        XCTAssertEqual(viewModel.filteredSources.first?.category, "sports")
    }

    func testApplyFilter_MultipleCategorySelection() {
        // Given
        viewModel.sources = [
            TestHelpers.createSource(id: "1", category: "general"),
            TestHelpers.createSource(id: "2", category: "sports"),
            TestHelpers.createSource(id: "3", category: "technology"),
        ]

        // When - select sports and technology
        viewModel.toggleCategory("sports")
        viewModel.toggleCategory("technology")

        // Then
        XCTAssertEqual(viewModel.filteredSources.count, 2)
    }
}
