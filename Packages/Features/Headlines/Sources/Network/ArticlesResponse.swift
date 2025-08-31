//
//  ArticlesResponse.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import Foundation

struct ArticlesResponse: Decodable {
    let articles: [Article]
}

struct Article: Codable, Identifiable {
    let id: UUID = .init()
    let source: Source
    let author: String?
    let title: String
    let description: String
    let url: String
    let urlToImage: String
    let publishedAt: String
    let content: String
}

extension Article {
    var authorName: String {
        author ?? source.name
    }

    var sourceName: String {
        source.name
    }
}

struct Source: Codable {
    let id: String
    let name: String
}
