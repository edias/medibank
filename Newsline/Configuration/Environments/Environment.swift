//
//  Environment.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

enum Environment: String {

    case development = "Development"
    case mock = "Mock"

    var requiresAPIKey: Bool {
        switch self {
        case .development: true
        case .mock: false
        }
    }

    var baseURL: String {
        switch self {
        case .development: "https://newsapi.org"
        case .mock: "http://localhost:8080" // For local mocking
        }
    }
}
