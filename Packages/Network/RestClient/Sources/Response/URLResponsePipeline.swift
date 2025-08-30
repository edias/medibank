//
//  URLResponsePipeline.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import Foundation

/// Defines a pipeline to transform raw `URLResponseData` into the expected endpoint response data.
protocol URLResponsePipeline {

    /// Converts `URLResponseData` to the endpoint’s expected response type.
    /// - Parameters:
    ///   - responseData: Raw data from the network response.
    ///   - clientRequest: The request describing the endpoint and expected response type.
    /// - Throws: If validation or deserialization fails.
    /// - Returns: The deserialized response data of type `Endpoint.ResponseData`.
    func makeEndpointResponseData<Endpoint>(
        _ responseData: URLResponseData,
        clientRequest: RestClientRequest<Endpoint>
    ) throws -> Endpoint.ResponseData

}

/// Default implementation of `URLResponsePipeline`.
/// Validates HTTP status codes and deserializes response bodies.
class DefaultURLResponsePipeline {

    let statusCodeValidator: URLStatusCodeValidator
    let serializer: Serializer

    /// Initializes the response pipeline.
    /// - Parameters:
    ///   - statusCodeValidator: Validator for HTTP status codes (default: `DefaultURLStatusCodeValidator`).
    ///   - serializer: Serializer for response data (default: `DefaultSerializer`).
    init(
        statusCodeValidator: URLStatusCodeValidator = DefaultURLStatusCodeValidator(),
        serializer: Serializer = DefaultSerializer()
    ) {
        self.statusCodeValidator = statusCodeValidator
        self.serializer = serializer
    }

}

extension DefaultURLResponsePipeline: URLResponsePipeline {

    /// Processes the raw network response and returns the endpoint’s expected response type.
    /// - Parameters:
    ///   - responseData: Raw data from the network response.
    ///   - clientRequest: The request describing the endpoint and expected response type.
    /// - Throws: Errors from status code validation or deserialization.
    /// - Returns: The deserialized response data.
    func makeEndpointResponseData<Endpoint>(
        _ responseData: URLResponseData,
        clientRequest: RestClientRequest<Endpoint>
    ) throws -> Endpoint.ResponseData {
        // 1. Validate HTTP status code.
        let responseData = try statusCodeValidator.validate(responseData, clientRequest: clientRequest)

        // 2. Deserialize the response body into the expected type.
        let endpointResponseData = try serializer.deserialize(clientRequest.responseType, data: responseData.data)

        // 3. Return the deserialized response data.
        return endpointResponseData
    }

}
