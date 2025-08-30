//
//  URLRequestBuilder.swift
//  Newsline
//
//  Created by Eduardo Dias on 28/08/2025.
//

import Foundation

/// Builds a `URLRequest` from a given `RestClientRequest`.
protocol URLRequestBuilder {

    /// Creates a `URLRequest` for the specified endpoint.
    ///
    /// - Parameters:
    ///   - restClientRequest: The rest client request containing endpoint and parameters.
    /// - Throws: If building the URLRequest fails (e.g., invalid URL or query parameters).
    /// - Returns: A fully configured `URLRequest`.
    func makeUrlRequest<Endpoint>(_ restClientRequest: RestClientRequest<Endpoint>) throws -> URLRequest
}

/// Builds `URLRequest` for a given endpoint using a URL host provider.
class DefaultURLRequestBuilder {

    private let urlHostProvider: URLHostProvider

    /// Initializes the builder with a URL host provider.
    /// - Parameter urlHostProvider: Provides the base URL/host for requests.
    init(_ urlHostProvider: URLHostProvider) {
        self.urlHostProvider = urlHostProvider
    }
}

extension DefaultURLRequestBuilder: URLRequestBuilder {

    /// Creates a `URLRequest` for the specified endpoint.
    /// - Parameters:
    ///   - restClientRequest: The request containing endpoint info.
    /// - Throws: `URLRequestBuilderError` if the URL or query parameters are invalid.
    /// - Returns: A fully configured `URLRequest`.
    func makeUrlRequest<Endpoint>(_ restClientRequest: RestClientRequest<Endpoint>) throws -> URLRequest {
        let baseUrl = urlHostProvider.urlHost.baseUrl

        // 1. Retrieve the network url path configured on the Endpoint.
        let endPointPath = restClientRequest.endpoint.path

        // 2. Make the full URL with host and path.
        let urlString = baseUrl + endPointPath

        // 3. Validate the URL with path.
        guard var urlComponents = URLComponents(string: urlString) else {
            throw URLRequestBuilderError.invalidUrl(urlString)
        }

        // 4. Set query parameters
        if !restClientRequest.queries.isEmpty {
            urlComponents.queryItems = restClientRequest.queries.items
        }

        // 5. Validate the url.
        guard let url = urlComponents.url else {
            throw URLRequestBuilderError.invalidQueryParameters
        }

        // 6. Make the request with the full URL.
        var urlRequest = URLRequest(url: url)

        // 7. Set the http method defined on the Endpoint.
        urlRequest.httpMethod = "\(restClientRequest.endpoint.requestType)"

        // 8. Return the URLRequest
        return urlRequest
    }
}

private extension Array where Element == [String: [String]] {
    var items: [URLQueryItem] {
        flatMap { dict -> [URLQueryItem] in
            dict.map { key, values in
                let values = values.joined(separator: ",")
                return URLQueryItem(name: key, value: values)
            }
        }
    }
}
