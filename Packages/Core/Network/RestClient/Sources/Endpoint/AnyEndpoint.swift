//
//  AnyEndpoint.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

/// Type-erased endpoint implementation for generic API requests.
///
/// Wraps request and response types to provide a consistent interface
/// for API endpoints while maintaining type safety.
///
/// - Parameters:
///   - RequestData: Encodable request body type
///   - ResponseData: Decodable response type
public struct AnyEndpoint<RequestData: Encodable & Sendable, ResponseData: Decodable>: Endpoint {

    /// HTTP method and request data
    public let requestType: RequestType<RequestData>

    /// Expected response type
    public let responseType: ResponseData.Type

    /// API endpoint path
    public let path: String

    /// URL query parameters
    public let queries: [[String: [String]]]

    /// Creates a type-erased endpoint
    init(
        requestType: RequestType<RequestData>,
        responseType: ResponseData.Type,
        path: String,
        queries: [[String: [String]]] = []
    ) {
        self.requestType = requestType
        self.responseType = responseType
        self.path = path
        self.queries = queries
    }

}
