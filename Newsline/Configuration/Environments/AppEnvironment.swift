//
//  AppEnvironment.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import Foundation

final class AppEnvironment {

    static let shared = AppEnvironment()

    let environment: Environment

    private init() {
        // Try to get environment from process info (set in scheme)
        if let envString = ProcessInfo.processInfo.environment["APP_ENVIRONMENT"],
           let environment = Environment(rawValue: envString)
        {
            guard environment == .development, !Bundle.main.apiKeyExists else {
                self.environment = environment
                print("Environment: Using `\(environment.rawValue)` from environment variable")
                return
            }

            assertionFailure("Warning: Development environment selected but no API key found. Falling back to mock.")
            self.environment = .mock
        }

        // Fallback to build settings for production vs debug
        else {
            #if DEBUG

                if Bundle.main.apiKeyExists {
                    environment = .development
                    print("Environment: Using development (DEBUG build with API key)")
                } else {
                    environment = .mock
                    print("Environment: Using mock (DEBUG build without API key)")
                }

            #else
                // For non-DEBUG builds, always use mock since we're not building for production
                environment = .mock
                print("Environment: Using mock (non-DEBUG build)")
            #endif
        }

        // Log the final environment decision
        print("Final environment: \(environment.rawValue)")
    }
}
