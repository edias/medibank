//
//  RestClient.swift
//  Newsline
//
//  Created by Eduardo Dias on 28/08/2025.
//

import Foundation

// A protocol for sending network requests.
public protocol RestClient: Sendable {

    /// Send a network request.
    ///
    /// - Parameter clientRequest: A RestClientRequest to be executed.
    /// - Returns: An asynchronous decodable data or an error in case of exceptions.
    func executeRequest<Endpoint>(_ clientRequest: RestClientRequest<Endpoint>) async throws -> Endpoint.ResponseData
}

/// Default implementation of the RestClient protocol.
public actor DefaultRestClient {

    /// The URL session used to perform network requests.
    ///
    /// Defaults to `RestClientSession.shared` but can be customized
    /// for testing or specific session configurations.
    let session: URLSessionProtocol

    /// The pipeline responsible for constructing URL requests from endpoint definitions.
    let requestPipeline: URLRequestPipeline

    /// The pipeline responsible for processing and decoding response data.
    let responsePipeline: URLResponsePipeline

    /// Creates a RestClient instance with default dependencies.
    ///
    /// - Parameters:
    ///   - session: The URL session to use for network requests.
    ///   - urlHostProvider: Provides base URL information for API endpoints.
    ///   - apiKeyProvider: Provides authentication credentials for API requests.
    public init(
        session: URLSessionProtocol = RestClientSession.shared,
        urlHostProvider: URLHostProvider,
        apiKeyProvider: APIKeyProvider
    ) {
        let requestPipeline = DefaultURLRequestPipeline(
            urlHostProvider: urlHostProvider,
            apiKeyProvider: apiKeyProvider
        )
        let responsePipeline = DefaultURLResponsePipeline()

        self.init(session: session, requestPipeline: requestPipeline, responsePipeline: responsePipeline)
    }

    /// Creates a RestClient instance with custom dependencies.
    ///
    /// Use this initializer when you need full control over the client's components,
    /// particularly for testing or specialized use cases.
    ///
    /// - Parameters:
    ///   - session: The URL session to use for network requests.
    ///   - requestPipeline: The pipeline for constructing URL requests.
    ///   - responsePipeline: The pipeline for processing responses.
    init(session: URLSessionProtocol, requestPipeline: URLRequestPipeline, responsePipeline: URLResponsePipeline) {
        self.session = session
        self.requestPipeline = requestPipeline
        self.responsePipeline = responsePipeline
    }
}

extension DefaultRestClient: RestClient {

    /// Executes a network request and returns the expected response body or throw a RestClientError.
    /// - Parameter clientRequest: A RestClientRequest to be executed.
    /// - Returns: An asynchronous response data.
    public func executeRequest<Endpoint>(_ clientRequest: RestClientRequest<Endpoint>) async throws -> Endpoint.ResponseData {
        do {
            let request = try requestPipeline.makeUrlRequest(clientRequest)
            let responseData = try await session.data(for: request)
            return try responsePipeline.makeEndpointResponseData(responseData, clientRequest: clientRequest)
        } catch {
            throw error
        }
    }
}
