//
//  SourceSelectionDependencies.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import RestClient
import SourceSelection

import Storage

struct DefaultSourceSelectionDependencies: SourceSelectionDependencies {
    let restClient: RestClient
    let selectionStorage: SelectionStorage
}
