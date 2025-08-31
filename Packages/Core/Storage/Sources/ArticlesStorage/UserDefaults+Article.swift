//
//  UserDefaults+Article.swift
//  Storage
//
//  Created by Eduardo Dias on 01/09/2025.
//

import Foundation

/// Protocol for storing and retrieving `Article` arrays.
public protocol ArticlesStore {
    
    /// Returns stored articles for a key. Empty if none.
    func articles(forKey key: String) -> [Article]

    /// Stores articles under a key.
    func storeArticles(_ articles: [Article], forKey key: String)
}

/// `UserDefaults` implementation of `ArticlesStore` using Codable.
extension UserDefaults: ArticlesStore {

    public func articles(forKey key: String) -> [Article] {
        guard let data = data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Article].self, from: data)) ?? []
    }

    public func storeArticles(_ articles: [Article], forKey key: String) {
        guard let data = try? JSONEncoder().encode(articles) else { return }
        set(data, forKey: key)
        synchronize()
    }
}
