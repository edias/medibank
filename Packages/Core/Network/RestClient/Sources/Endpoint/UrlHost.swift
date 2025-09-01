//
//  UrlHost.swift
//  Newsline
//
//  Created by Eduardo Dias on 28/08/2025.
//

/// Represents a URL host with a base URL string.
public protocol UrlHost {
    var baseUrl: String { get }
}

/// Default implementation of UrlHost with configurable base URL.
public struct DefaultUrlHost: UrlHost {

    public let baseUrl: String

    public init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
}
