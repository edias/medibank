//
//  File.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import SwiftUI

import RestClient
import Storage

public protocol HeadlinesDependencies {
    var restClient: RestClient { get }
    var selectionStorage: SelectionStorage { get }
    var onTapHeadline: @MainActor (URL) -> Void { get }
}

public protocol FeatureFactory {
    associatedtype RootView: View
    func makeRootView() -> RootView
}

public struct HeadlinesFactory: @preconcurrency FeatureFactory {

    private let dependencies: HeadlinesDependencies

    public init(_ dependencies: HeadlinesDependencies) {
        self.dependencies = dependencies
    }

    @MainActor
    public func makeRootView() -> some View {

        let networkServices = DefaultHeadlinesNetworkServices(restClient: dependencies.restClient)

        let viewModel = HeadlinesViewModel(
            networkServices: networkServices,
            storage: dependencies.selectionStorage,
            onTapHeadline: dependencies.onTapHeadline
        )

        return HeadlinesView(viewModel)
    }
}
