//
//  File.swift
//  Storage
//
//  Created by Eduardo Dias on 01/09/2025.
//

import Foundation
import Combine

public protocol ArticlesStorage {
    
    var articles: [Article] { get }

    var articlesPublisher: AnyPublisher<[Article], Never> { get }

    func toggleArticle(for article: Article)

    func removeArticle(_ urlString: String)

    func isArticleSaved(_ urlString: String) -> Bool
}

public final class DefaultArticlesStorage: ArticlesStorage {

    private var storedArticles: [Article] = [] {
        didSet { subject.send(storedArticles) }
    }

    public var articles: [Article] {
        storedArticles
    }

    private let key = "articles"
    private let defaults: UserDefaults
    private let subject = CurrentValueSubject<[Article], Never>([])

    public var articlesPublisher: AnyPublisher<[Article], Never> {
        subject.eraseToAnyPublisher()
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let saved = defaults.articles(forKey: key)
        self.storedArticles = saved
        subject.send(saved)
    }

    public func toggleArticle(for article: Article) {
        if let index = storedArticles.firstIndex(where: { $0.url == article.url }) {
            storedArticles.remove(at: index)
        } else {
            storedArticles.append(article)
        }
        updateStorage()
    }

    public func removeArticle(_ urlString: String) {
        storedArticles.removeAll { $0.url == urlString }
        updateStorage()
    }

    public func isArticleSaved(_ urlString: String) -> Bool {
        storedArticles.contains { $0.url == urlString }
    }

    public func addArticle(_ article: Article) {
        if !isArticleSaved(article.url) {
            storedArticles.append(article)
            updateStorage()
        }
    }

    private func updateStorage() {
        defaults.storeArticles(storedArticles, forKey: key)
    }
}


