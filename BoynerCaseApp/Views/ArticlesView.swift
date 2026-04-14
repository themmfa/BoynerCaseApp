//
//  ArticlesView.swift
//  BoynerCaseApp
//
//  Created by F E on 14.04.2026.
//

import SwiftUI

struct ArticlesView: View {
    @StateObject private var viewModel: ArticlesViewModel

    init(sourceId: String, sourceName: String) {
        _viewModel = StateObject(wrappedValue: ArticlesViewModel(
            sourceId: sourceId,
            sourceName: sourceName
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.articles.isEmpty {
                Spacer()
                ProgressView("Loading articles...")
                Spacer()
            } else if viewModel.showError {
                // Error view with retry button
                Spacer()
                errorView
                Spacer()
            } else if viewModel.articles.isEmpty {
                Spacer()
                Text("No articles found")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                articlesList
            }
        }
        .navigationTitle(viewModel.sourceName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchArticles()
            viewModel.startSliderTimer()
            viewModel.startAutoRefresh()
        }
        .onDisappear {
            viewModel.stopSliderTimer()
            viewModel.stopAutoRefresh()
        }
    }

    // MARK: - Articles List with Slider
    private var articlesList: some View {
        List {
            // Slider section for top 3 articles
            if !viewModel.sliderArticles.isEmpty {
                Section {
                    sliderView
                        .listRowInsets(EdgeInsets())
                }
            }

            // Remaining articles
            Section(header: Text("Articles")) {
                ForEach(viewModel.listArticles) { article in
                    ArticleRowView(
                        article: article,
                        isInReadingList: viewModel.isInReadingList(article),
                        onToggleReadingList: {
                            viewModel.toggleReadingList(article)
                        }
                    )
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refreshArticles()
        }
    }

    // MARK: - Slider View
    private var sliderView: some View {
        TabView(selection: $viewModel.currentSliderIndex) {
            ForEach(Array(viewModel.sliderArticles.enumerated()), id: \.element.id) { index, article in
                SliderItemView(
                    article: article,
                    isInReadingList: viewModel.isInReadingList(article),
                    onToggleReadingList: {
                        viewModel.toggleReadingList(article)
                    }
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 260)
    }

    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)

            Text(viewModel.errorMessage ?? "Bilgiler alınamadı!")
                .font(.headline)
                .multilineTextAlignment(.center)

            Button("Tekrar Dene") {
                Task {
                    await viewModel.fetchArticles()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Slider Item View
struct SliderItemView: View {
    let article: Article
    let isInReadingList: Bool
    let onToggleReadingList: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Article image
            if let imageURL = article.urlToImage, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .clipped()
                    case .failure:
                        imagePlaceholder
                    case .empty:
                        ProgressView()
                            .frame(height: 150)
                    @unknown default:
                        imagePlaceholder
                    }
                }
            } else {
                imagePlaceholder
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                HStack {
                    Text(article.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button(action: onToggleReadingList) {
                        Text(isInReadingList ? "Okuma listemden çıkar" : "Okuma listeme ekle")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(isInReadingList ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                            .foregroundColor(isInReadingList ? .red : .blue)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 150)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            )
    }
}

// MARK: - Article Row View
struct ArticleRowView: View {
    let article: Article
    let isInReadingList: Bool
    let onToggleReadingList: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // Thumbnail
                if let imageURL = article.urlToImage, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                .clipped()
                        case .failure:
                            thumbnailPlaceholder
                        case .empty:
                            ProgressView()
                                .frame(width: 80, height: 80)
                        @unknown default:
                            thumbnailPlaceholder
                        }
                    }
                } else {
                    thumbnailPlaceholder
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(3)

                    Text(article.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Reading list button
            Button(action: onToggleReadingList) {
                HStack {
                    Image(systemName: isInReadingList ? "bookmark.fill" : "bookmark")
                    Text(isInReadingList ? "Okuma listemden çıkar" : "Okuma listeme ekle")
                }
                .font(.caption)
                .foregroundColor(isInReadingList ? .red : .blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    private var thumbnailPlaceholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .font(.caption)
            )
    }
}
