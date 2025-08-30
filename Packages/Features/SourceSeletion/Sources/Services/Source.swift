//
//  Source.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

struct SourcesResponse: Codable {
    let status: String
    let sources: [Source]
}

struct Source: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let url: String
    let category: String
    let language: String
    let country: String
}
