//
//  Encoder.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import Foundation

/// Protocol defining data encoding capabilities
protocol DataEncoder {
    func encode(_ value: some Encodable) throws -> Data
}

/// Protocol defining data decoding capabilities
protocol DataDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}

/// JSONEncoder conformance to DataEncoder protocol
extension JSONEncoder: DataEncoder {}

/// JSONDecoder conformance to DataDecoder protocol
extension JSONDecoder: DataDecoder {}
