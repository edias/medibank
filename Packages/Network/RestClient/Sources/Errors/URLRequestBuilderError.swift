//
//  URLRequestBuilderError.swift
//  Newsline
//
//  Created by Eduardo Dias on 28/08/2025.
//

/// Errors that can occur during URL request construction.
enum URLRequestBuilderError: Error, CustomStringConvertible {

    /// The URL string is invalid and cannot be converted to a URL.
    case invalidUrl(String)

    /// The query parameters are invalid and cannot be encoded.
    case invalidQueryParameters

    /// A human-readable description of the error.
    var description: String {
        switch self {
        case let .invalidUrl(url):
            "Invalid URL \(url)"
        case .invalidQueryParameters:
            "Invalid queryString"
        }
    }
}
