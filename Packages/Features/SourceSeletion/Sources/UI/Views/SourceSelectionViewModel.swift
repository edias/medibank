//
//  SourceSelectionViewModel.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

import Foundation

final class SourceSelectionViewModel: ObservableObject {

    @Published
    var sources: [Source] = []

    @Published
    private(set) var selectedSourceIds: Set<String> = []

    let networkServices: SourcesNetworkServices

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

    func toggleSource(_ source: Source) {
        if selectedSourceIds.contains(source.id) {
            selectedSourceIds.remove(source.id)
        } else {
            selectedSourceIds.insert(source.id)
        }
    }
}
