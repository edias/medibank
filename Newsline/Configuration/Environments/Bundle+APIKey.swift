//
//  Bundle+APIKey.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import Foundation

extension Bundle {

    var apiKey: String? {
        object(forInfoDictionaryKey: "API_KEY") as? String
    }

    var apiKeyExists: Bool {
        apiKey != nil
    }
}
