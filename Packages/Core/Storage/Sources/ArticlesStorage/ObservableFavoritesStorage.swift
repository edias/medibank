//
//  ObservableFavoritesStorage.swift
//  Storage
//
//  Created by Eduardo Dias on 01/09/2025.
//

import Combine
import Foundation

public final class ObservableArticlesStorage: ObservableObject {

    @Published
    private(set) var articles: [Article] = []

    private let storage: ArticlesStorage
    private var cancellables = Set<AnyCancellable>()

    public init(storage: ArticlesStorage) {

        self.storage = storage
        // swiftformat:disable:next redundantSelf
        self.articles = storage.articles

        storage.articlesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.articles, on: self)
            .store(in: &cancellables)
    }

    public func toggleArticle(for article: Article) {
        storage.toggleArticle(for: article)
    }

    public func removeArticle(_ urlString: String) {
        storage.removeArticle(urlString)
    }

    public func isArticleSaved(_ urlString: String) -> Bool {
        storage.isArticleSaved(urlString)
    }
}
