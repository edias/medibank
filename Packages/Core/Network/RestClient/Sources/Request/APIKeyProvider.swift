//
//  APIKeyProvider.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import Foundation

/// Provides an API key for authenticating network requests.
public protocol APIKeyProvider {
    var apiKey: String? { get }
}
