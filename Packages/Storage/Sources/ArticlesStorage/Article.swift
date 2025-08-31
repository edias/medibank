//
//  Article.swift
//  Storage
//
//  Created by Eduardo Dias on 01/09/2025.
//

import Foundation

public struct Article: Codable, Identifiable, Sendable {
    
    public var id: UUID = .init()
    public let source: ArticleSource
    public let author: String?
    public let title: String
    public let description: String
    public let url: String
    public let urlToImage: String
    public let publishedAt: String

    enum CodingKeys: String, CodingKey {
        case source, author, title, description, url, urlToImage, publishedAt
    }
}

extension Article {
    public var authorName: String {
        author ?? source.name
    }

    public var sourceName: String {
        source.name
    }
}

public struct ArticleSource: Codable, Sendable {
    public let id: String
    public let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
