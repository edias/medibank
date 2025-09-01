//
//  FavoritesViewModel.swift
//  Favorites
//
//  Created by Eduardo Dias on 01/09/2025.
//

import SwiftUI

import Combine
import Storage

import CommonUI

@MainActor
final class FavoritesViewModel: ObservableObject {
    
    @Published var savedArticles: [Article] = []
    
    private let articlesStorage: ArticlesStorage
    private var cancellables = Set<AnyCancellable>()

    let onTapFavorite: (Article) -> Void

    var emptyState: EmptyState {
        .init(iconName: "heart", title: "No Favorites Yet", description: "Save articles from Headlines to see them here")
    }

    init(articlesStorage: ArticlesStorage, onTapFavorite: @escaping (Article) -> Void) {

        self.articlesStorage = articlesStorage
        self.onTapFavorite = onTapFavorite
        
        articlesStorage.articlesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] articles in
                self?.savedArticles = articles
            }
            .store(in: &cancellables)
    }
    
    func loadFavorites() {
        savedArticles = articlesStorage.articles
    }
        
    func deleteArticles(at offsets: IndexSet) {
        for index in offsets {
            let article = savedArticles[index]
            articlesStorage.removeArticle(article.url)
        }
    }
}
