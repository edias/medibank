//
//  Endpoint.swift
//  Newsline
//
//  Created by Eduardo Dias on 28/08/2025.
//

/// Defines an API endpoint with request and response types.
///
/// Generic protocol for type-safe network requests.
///
/// - AssociatedTypes:
///   - RequestData: Encodable request body type
///   - ResponseData: Decodable response type
public protocol Endpoint {

    associatedtype RequestData: Encodable
    associatedtype ResponseData: Decodable

    /// HTTP method and optional request data
    var requestType: RequestType<RequestData> { get }

    /// Expected response type for decoding
    var responseType: ResponseData.Type { get }

    /// API endpoint path
    var path: String { get }

    /// URL query parameters
    var queries: [[String: [String]]] { get }
}

extension Endpoint {

    /// Default empty query parameters
    var queries: [[String: [String]]] { [] }

    /// Creates a request instance for this endpoint
    func makeRequest() -> RestClientRequest<Self> {
        RestClientRequest(self)
    }
}
