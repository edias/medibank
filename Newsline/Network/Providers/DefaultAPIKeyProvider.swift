//
//  DefaultAPIKeyProvider.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import Foundation
import RestClient

struct DefaultAPIKeyProvider: APIKeyProvider {

    let environment: Environment

    var apiKey: String? {

        guard environment.requiresAPIKey else { return nil }

        guard let apiKey = Bundle.main.apiKey, !apiKey.isEmpty else {
            // This shouldn't happen if EnvironmentManager is working correctly
            print("Error: API key required for development but not found in Info.plist")
            return nil
        }

        return apiKey
    }
}
