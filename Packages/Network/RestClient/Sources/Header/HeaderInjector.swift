//
//  HeaderInjector.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import Foundation

/// A protocol responsible for injecting HTTP headers into a `URLRequest`.
///
/// Conforming types define how headers (like `Content-Type` or API keys)
/// are added to requests before they are sent.
protocol HeaderInjector {

    /// Inject headers into a given `URLRequest`.
    ///
    /// - Parameters:
    ///   - urlRequest: The original URLRequest to modify.
    ///   - clientRequest: The associated `RestClientRequest` providing context.
    ///   - apiKeyProvider: The provider responsible for supplying an API key, if needed.
    /// - Returns: A new `URLRequest` instance containing the injected headers.
    func inject<Endpoint>(
        intoRequest urlRequest: URLRequest,
        clientRequest: RestClientRequest<Endpoint>,
        apiKeyProvider: APIKeyProvider
    ) -> URLRequest
}

/// Default implementation of `HeaderInjector`.
///
/// Injects common headers such as `Content-Type` and API key into the request.
class DefaultHeaderInjector {}

extension DefaultHeaderInjector: HeaderInjector {

    /// Injects headers into the provided `URLRequest`.
    ///
    /// Sets:
    /// - `Content-Type` from the `clientRequest`
    /// - API key from the `apiKeyProvider`
    ///
    /// - Parameters:
    ///   - urlRequest: The original request.
    ///   - clientRequest: The associated `RestClientRequest`.
    ///   - apiKeyProvider: Supplies the API key, if required.
    /// - Returns: A new `URLRequest` with the headers applied.
    func inject<Endpoint>(
        intoRequest urlRequest: URLRequest,
        clientRequest: RestClientRequest<Endpoint>,
        apiKeyProvider: APIKeyProvider
    ) -> URLRequest {
        // 1. Make a copy of the URLRequest passed.
        var urlRequest = urlRequest

        // 2. Set the header content type.
        urlRequest[.contentType] = clientRequest.contentType

        // 3. Set the URL API key.
        urlRequest[.apiKey] = apiKeyProvider.apiKey

        // 4. Returns a copt of the modifed URLRequest with the header parameters.
        return urlRequest
    }
}
