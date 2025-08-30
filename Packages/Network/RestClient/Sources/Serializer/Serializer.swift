//
//  Serializer.swift
//  Newsline
//
//  Created by Eduardo Dias on 28/08/2025.
//

import Foundation

typealias URLResponseData = (data: Data, response: URLResponse)

/// A wrapper for encoding and decoding data to and from `Encodable`/`Decodable` types.
protocol Serializer {

    /// Serializes an `Encodable` object into `Data`.
    /// - Parameter encodable: The object to serialize.
    /// - Throws: If encoding fails.
    /// - Returns: The serialized `Data`.
    func serialize(_ encodable: Encodable) throws -> Data

    /// Deserializes `Data` into a `Decodable` type.
    /// - Parameters:
    ///   - type: The type to decode into.
    ///   - data: The data to decode.
    /// - Throws: If decoding fails.
    /// - Returns: The decoded object of the specified type.
    func deserialize<D: Decodable>(_ type: D.Type, data: Data) throws -> D
}

/// Default implementation of `Serializer` using `JSONEncoder` and `JSONDecoder`.
class DefaultSerializer: Serializer {

    private let dataEncoder: DataEncoder
    private let dataDecoder: DataDecoder

    /// Initializes the serializer with optional custom encoder/decoder.
    /// - Parameters:
    ///   - dataEncoder: Encoder to use (default: `JSONEncoder`).
    ///   - dataDecoder: Decoder to use (default: `JSONDecoder`).
    init(dataEncoder: DataEncoder = JSONEncoder(), dataDecoder: DataDecoder = JSONDecoder()) {
        self.dataEncoder = dataEncoder
        self.dataDecoder = dataDecoder
    }

    func serialize(_ encodable: Encodable) throws -> Data {
        try dataEncoder.encode(encodable)
    }

    func deserialize<D: Decodable>(_ type: D.Type, data: Data) throws -> D {
        try dataDecoder.decode(type, from: data)
    }
}
