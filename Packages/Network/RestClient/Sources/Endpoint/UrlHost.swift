//
//  UrlHost.swift
//  Newsline
//
//  Created by Eduardo Dias on 28/08/2025.
//

/// Represents a URL host with a base URL string.
protocol UrlHost {
    var baseUrl: String { get }
}

/// Default implementation of UrlHost with configurable base URL.
struct DefaultUrlHost: UrlHost {
    let baseUrl: String
}
