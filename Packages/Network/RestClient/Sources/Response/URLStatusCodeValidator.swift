//
//  URLStatusCodeValidator.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import Foundation

/// Validates response status codes(200, 400, 500, etc) and returns an URLResponseData
/// or throw an error on the stream in case of invalid state.
protocol URLStatusCodeValidator {

    /// Check if the response status code is 200 and returns the URLResponseData.
    /// If the status code is not 200, an error is thrown on the stream.
    ///
    /// - Parameters:
    ///   - responseData: The URLResponseData to validate.
    ///   - clientRequest:  A rest client request to be executed.
    /// - Returns: An URLResponseData in case of valid status(200).
    func validate(_ responseData: URLResponseData, clientRequest: RestClientRequest<some Any>) throws -> URLResponseData
}

class DefaultURLStatusCodeValidator {}

extension DefaultURLStatusCodeValidator: URLStatusCodeValidator {

    func validate(
        _ responseData: URLResponseData,
        clientRequest _: RestClientRequest<some Any>
    ) throws -> URLResponseData {
        guard let response = responseData.response as? HTTPURLResponse else {
            throw ServerError.httpURLResponseConversion(responseData)
        }

        switch response.statusCode {
        case 200 ..< 300:
            return responseData

        default:
            throw ServerError.unknown(responseData)
        }
    }
}
