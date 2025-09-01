//
//  FavoritesViewModel.swift
//  Favorites
//
//  Created by Eduardo Dias on 01/09/2025.
//

import SwiftUI

import Combine
import Storage

@MainActor
final class FavoritesViewModel: ObservableObject {

    var title: String { Constants.title }
    var loadingText: String { Constants.loadingText }

    @Published
    private(set) var viewState: FavoritesViewState = .loading

    var savedArticles: [Article] {
        guard case let .loaded(articles) = viewState else { return [] }
        return articles
    }

    private let articlesStorage: ArticlesStorage
    private var cancellables = Set<AnyCancellable>()

    let onTapFavorite: (Article) -> Void

    init(articlesStorage: ArticlesStorage, onTapFavorite: @escaping (Article) -> Void) {

        self.articlesStorage = articlesStorage
        self.onTapFavorite = onTapFavorite

        articlesStorage.articlesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] articles in
                self?.updateViewState(with: articles)
            }
            .store(in: &cancellables)
    }

    func loadFavorites() {
        viewState = .loading
        let articles = articlesStorage.articles
        updateViewState(with: articles)
    }

    private func updateViewState(with articles: [Article]) {
        viewState = articles.isEmpty ? .empty(StateFactory.makeEmptyFavoritesState()) : .loaded(articles)
    }

    func deleteArticles(at offsets: IndexSet) {

        guard case let .loaded(articles) = viewState else { return }

        for index in offsets {
            let article = articles[index]
            articlesStorage.removeArticle(article.url)
        }
    }
}
