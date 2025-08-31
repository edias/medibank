//
//  URLRequestPipeline.swift
//  Newsline
//
//  Created by Eduardo Dias on 28/08/2025.
//

import Foundation

/// A protocol that defines a pipeline to transform a `RestClientRequest` into a `URLRequest`.
///
/// Implementations handle request construction, body serialization, and header injection.
protocol URLRequestPipeline {

    /// Creates a `URLRequest` from a given `RestClientRequest`.
    ///
    /// - Parameter clientRequest: The request to be executed by the REST client.
    /// - Returns: A fully configured `URLRequest`.
    /// - Throws: Any error thrown during URL building or request body serialization.
    func makeUrlRequest<Endpoint>(_ clientRequest: RestClientRequest<Endpoint>) throws -> URLRequest
}

/// Default implementation of `URLRequestPipeline`.
///
/// Uses a `URLRequestBuilder` to construct the request URL, a `Serializer` to encode the request body,
/// and a `HeaderInjector` to inject headers (including API keys).
class DefaultURLRequestPipeline {

    /// Responsible for constructing the URL and query parameters.
    let requestBuilder: URLRequestBuilder

    /// Responsible for serializing request bodies and decoding response bodies.
    let serializer: Serializer

    /// Responsible for injecting headers into the request, including API keys.
    let headerInjector: HeaderInjector

    /// Provides the API key for authenticated requests.
    let apiKeyProvider: APIKeyProvider

    /// Convenience initializer using a `URLHostProvider` and `APIKeyProvider`.
    convenience init(urlHostProvider: URLHostProvider, apiKeyProvider: APIKeyProvider) {
        self.init(requestBuilder: DefaultURLRequestBuilder(urlHostProvider), apiKeyProvider: apiKeyProvider)
    }

    /// Designated initializer.
    ///
    /// - Parameters:
    ///   - requestBuilder: The URL request builder.
    ///   - serializer: The serializer to encode request bodies (default: `DefaultSerializer`).
    ///   - headerInjector: The header injector (default: `DefaultHeaderInjector`).
    ///   - apiKeyProvider: The API key provider.
    init(
        requestBuilder: URLRequestBuilder,
        serializer: Serializer = DefaultSerializer(),
        headerInjector: HeaderInjector = DefaultHeaderInjector(),
        apiKeyProvider: APIKeyProvider
    ) {
        self.requestBuilder = requestBuilder
        self.serializer = serializer
        self.headerInjector = headerInjector
        self.apiKeyProvider = apiKeyProvider
    }
}

extension DefaultURLRequestPipeline: URLRequestPipeline {

    /// Builds a `URLRequest` from a `RestClientRequest`.
    ///
    /// Steps:
    /// 1. Build the URL and query parameters using `requestBuilder`.
    /// 2. Serialize the request body, if any.
    /// 3. Inject headers, including `Content-Type` and API key.
    /// 4. Return the final `URLRequest`.
    ///
    /// - Parameter clientRequest: The `RestClientRequest` to convert.
    /// - Returns: A fully configured `URLRequest`.
    /// - Throws: Any error that occurs during URL building or body serialization.
    func makeUrlRequest<Endpoint>(_ clientRequest: RestClientRequest<Endpoint>) throws -> URLRequest {
        // 1. Creates an URLRequest.
        var urlRequest = try requestBuilder.makeUrlRequest(clientRequest)

        // 2. Serialize the request body and set to URLRequest.
        if let body = clientRequest.requestType.body {
            urlRequest.httpBody = try serializer.serialize(body)
        }

        // 3. Inject headers from the RestClient and APIKeyProvider.
        urlRequest = headerInjector.inject(
            intoRequest: urlRequest,
            clientRequest: clientRequest,
            apiKeyProvider: apiKeyProvider
        )

        // 4. Returns a URLRequest.
        return urlRequest
    }
}
