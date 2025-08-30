//
//  RequestType.swift
//  Newsline
//
//  Created by Eduardo Dias on 28/08/2025.
//

import Foundation

/// Request types are the HTTP verbs used on REST APIs.
public enum RequestType<E: Encodable> {
    case get
    case post(_ requestBody: E)
    case put(_ requestBody: E)
}

extension RequestType {

    /// The value for the **Content-Type** of URLRequests.
    var contentType: String { ContentType.json.rawValue }

    /// The value for the **Accept header** field of URLRequests.
    var acceptContentType: String { ContentType.json.rawValue }

    /// The body data that will be included to certain RequestTypes.
    var body: E? {
        switch self {
        case .get:
            nil

        case let .post(body):
            body

        case let .put(body):
            body
        }
    }
}

/// The string representation of a HTTP method.
extension RequestType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .get: "GET"
        case .post: "POST"
        case .put: "PUT"
        }
    }
}
