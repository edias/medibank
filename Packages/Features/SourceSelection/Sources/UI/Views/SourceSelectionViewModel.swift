//
//  SourceSelectionViewModel.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

import Foundation
import Storage

final class SourceSelectionViewModel: ObservableObject {

    let title = "list_title".localized()

    @Published
    var sources: [Source] = []

    private let networkServices: SourcesNetworkServices

    init(networkServices: SourcesNetworkServices) {
        self.networkServices = networkServices
    }

    @MainActor
    func loadSources() async {
        do {
            sources = try await networkServices.fetchSources()
        } catch {
            // TODO: Handle error scenario
        }
    }
}
