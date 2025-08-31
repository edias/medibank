//
//  URLHostProvider.swift
//  Newsline
//
//  Created by Eduardo Dias on 28/08/2025.
//

import Foundation

/// Provides a URL host for network requests.
public protocol URLHostProvider {
    var urlHost: UrlHost { get }
}

/// Default implementation of URLHostProvider with configurable UrlHost.
public struct DefaultURLHostProvider: URLHostProvider {
    public let urlHost: UrlHost
}
