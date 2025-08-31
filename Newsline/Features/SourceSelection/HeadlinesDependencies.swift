//
//  SourceSelectionDependencies.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import Headlines

import RestClient
import Storage

import Foundation

struct DefaultHeadlinesDependencies: HeadlinesDependencies {
    let restClient: RestClient
    let selectionStorage: SelectionStorage
    let onTapHeadline: @MainActor (URL) -> Void
}
