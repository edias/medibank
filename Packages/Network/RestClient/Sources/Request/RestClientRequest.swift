//
//  RestClientRequest.swift
//  Newsline
//
//  Created by Eduardo Dias on 28/08/2025.
//

/// A concrete implementation and configuration to execute a network request.
struct RestClientRequest<EndpointInstance: Endpoint> {

    /// An instance of the Endpoint requested.
    let endpoint: EndpointInstance

    /// The Endpoint url content type (application/json, application/x-www-form-urlencoded, etc).
    var acceptContentType: String { endpoint.requestType.acceptContentType }

    /// The Endpoint content type.
    var contentType: String { endpoint.requestType.contentType }

    /// The Endpoint requestType type.
    var requestType: RequestType<EndpointInstance.RequestData> { endpoint.requestType }

    /// The Endpoint response type.
    var responseType: EndpointInstance.ResponseData.Type { endpoint.responseType }

    var queries: [[String: [String]]] { endpoint.queries }

    init(_ endpoint: EndpointInstance) {
        self.endpoint = endpoint
    }
}
