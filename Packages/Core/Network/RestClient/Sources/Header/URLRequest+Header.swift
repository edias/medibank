//
//  URLRequest+Header.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import Foundation

// Utility to handle URLRequest header manipulation.
extension URLRequest {

    // Allows retrieving and setting common headers with subscripts from the URLRequest.
    subscript(header: Header) -> String? {
        get { allHTTPHeaderFields?[header.rawValue] }
        set {
            guard let newValue = newValue else { return }
            setValue(newValue, forHTTPHeaderField: header.rawValue)
        }
    }

    /// Merge a given dictionary to an existing URLRequest headers.
    /// If a field does not exist it will be added and if the field
    /// already exist, ot will be overwitten.
    ///
    /// - Parameter headers: A dictionary to be mergeed.
    mutating func mergeHeaders(_ headers: [String: String]) {
        allHTTPHeaderFields?.merge(headers) { _, new in new }
    }
}
