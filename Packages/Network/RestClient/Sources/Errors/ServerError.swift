//
//  ServerError.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import Foundation

/// Represents server-related errors that can occur during network operations.
enum ServerError: Error {

    /// Indicates that a URLResponse could not be converted to HTTPURLResponse.
    case httpURLResponseConversion(URLResponseData)

    /// Represents an unknown server error that couldn't be mapped to a specific type.
    case unknown(URLResponseData)

    /// A human-readable description of the error reason.
    var failureReason: String? {
        switch self {
        case .httpURLResponseConversion:
            "The response object could not be converted to HTTPResponse"
        case .unknown:
            "This server error could not be mapped and evaluated on URLStatusCodeValidator"
        }
    }

    /// The HTTP status code associated with the error, if available.
    var statusCode: Int {
        switch self {
        case let .unknown(data) where data.response is HTTPURLResponse,
             let .httpURLResponseConversion(data) where data.response is HTTPURLResponse:
            // swiftlint:disable:next force_cast
            (data.response as! HTTPURLResponse).statusCode
        default: 0
        }
    }
}

extension ServerError: Equatable {

    static func == (lhs: ServerError, rhs: ServerError) -> Bool {
        switch (lhs, rhs) {
        case let (unknown(leftData), unknown(rightData)):
            leftData == rightData
        case let (httpURLResponseConversion(leftData), httpURLResponseConversion(rightData)):
            leftData == rightData
        default:
            false
        }
    }
}
