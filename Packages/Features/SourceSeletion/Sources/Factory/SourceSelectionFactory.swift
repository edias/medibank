//
//  SourceSelectionFactory.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

import RestClient
import SwiftUI

public protocol SourceSelectionDependencies {
    var restClient: RestClient { get }
}

public protocol FeatureFactory {
    associatedtype RootView: View
    func makeRootView() -> RootView
}

public struct SourceSelectionFactory: @preconcurrency FeatureFactory {

    private let dependencies: SourceSelectionDependencies

    public init(_ dependencies: SourceSelectionDependencies) {
        self.dependencies = dependencies
    }

    @MainActor
    public func makeRootView() -> some View {
        let networkServices = DefaultSourcesNetworkServices(restClient: dependencies.restClient)
        let viewModel = SourceSelectionViewModel(networkServices: networkServices)
        return SourceSelectionView(viewModel)
    }
}
