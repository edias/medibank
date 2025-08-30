//
//  EndpointBuilder.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

/// Fluent builder for creating type-safe API endpoints.
///
/// Provides a chainable interface for configuring HTTP endpoints
/// with request/response types, paths, and query parameters.
///
/// - Generic Parameters:
///   - RequestData: Encodable request body type
///   - ResponseData: Decodable response type
class EndpointBuilder<RequestData: Encodable, ResponseData: Decodable> {

    private var requestType: RequestType<RequestData>
    private var path: String = ""
    private var queries: [[String: [String]]] = []

    private init(requestType: RequestType<RequestData>) {
        self.requestType = requestType
    }

    // MARK: - Static Factory Methods

    /// Creates a GET endpoint builder
    static func get(path: String = "") -> EndpointBuilder {
        let builder = EndpointBuilder(requestType: .get)
        builder.path = path
        return builder
    }

    /// Creates a POST endpoint builder with request data
    static func post(_ requestData: RequestData, path: String = "") -> EndpointBuilder {
        let builder = EndpointBuilder(requestType: .post(requestData))
        builder.path = path
        return builder
    }

    /// Creates a PUT endpoint builder with request data
    static func put(_ requestData: RequestData, path: String = "") -> EndpointBuilder {
        let builder = EndpointBuilder(requestType: .put(requestData))
        builder.path = path
        return builder
    }

    // MARK: - Fluent Configuration Methods

    /// Sets the endpoint path
    func withPath(_ path: String) -> Self {
        self.path = path
        return self
    }

    /// Adds a query parameter with single value
    func withQuery(_ key: String, value: String) -> Self {
        let query = [key: [value]]
        queries.append(query)
        return self
    }

    /// Adds a query parameter with multiple values
    func withQuery(_ key: String, values: [String]) -> Self {
        let query = [key: values]
        queries.append(query)
        return self
    }

    // MARK: - Build Method

    /// Constructs the final AnyEndpoint instance
    func build() -> AnyEndpoint<RequestData, ResponseData> {
        AnyEndpoint(
            requestType: requestType,
            responseType: ResponseData.self,
            path: path,
            queries: queries
        )
    }
}
