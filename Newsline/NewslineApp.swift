//
//  NewslineApp.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI
import SwiftData

@main
struct NewslineApp: App {

    private let dependencies = FeatureDependencies()

    var body: some Scene {
        WindowGroup {
            NewslineTabView(dependencies: dependencies)
        }
    }
}
