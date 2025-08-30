//
//  DefaultHostProvider.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import RestClient

struct DefaultHostProvider: URLHostProvider {

    let environment: Environment

    var urlHost: UrlHost {
        DefaultUrlHost(baseUrl: environment.baseURL)
    }
}
