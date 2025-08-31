//
//  RestClientSession.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import Foundation

/// Protocol defining the minimal interface required for URL session data tasks.
///
/// This protocol abstracts URLSession's data fetching capability, enabling
/// easier testing and implementation swapping.
public protocol URLSessionProtocol: Sendable {
    /// Fetches data from the specified URL request.
    ///
    /// - Parameter request: The URL request to execute.
    /// - Returns: A tuple containing the response data and URL response.
    /// - Throws: An error if the request fails.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// Extends URLSession to conform to URLSessionProtocol.
///
/// This allows URLSession to be used interchangeably with other URLSessionProtocol implementations.
extension URLSession: URLSessionProtocol {}

/// Provides shared URLSession instances for REST client operations.
///
/// Centralizes URLSession configuration management across the application.
public enum RestClientSession {
    /// Shared URLSession instance with default configuration.
    ///
    /// Suitable for most network requests with default caching and timeout behaviors.
    public static let shared = URLSession(configuration: .default)
}
