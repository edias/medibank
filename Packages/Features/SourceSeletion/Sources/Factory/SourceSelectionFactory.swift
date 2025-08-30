//
//  File.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI
import RestClient

public protocol SourceSelectionDependencies {
    var restClient: RestClient { get }
}

public protocol FeatureFactory {
    associatedtype RootView: View
    func makeRootView() -> RootView
}

public struct SourceSelectionFactory: FeatureFactory {

    private let dependencies: SourceSelectionDependencies

    public init(_ dependencies: SourceSelectionDependencies) {
        self.dependencies = dependencies
    }

    public func makeRootView() -> some View {
        SourceSelectionView()
    }
}
