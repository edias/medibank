//
//  HeadlinesViewState.swift
//  Headlines
//
//  Created by Eduardo Dias on 01/09/2025.
//

import CommonUI
import Storage

enum HeadlinesViewState {
    case loading
    case loaded([Article])
    case error(EmptyState)
    case noSourcesSelected(EmptyState)
}
