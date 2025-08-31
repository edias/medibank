//
//  File.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 31/08/2025.
//

import Combine
import Foundation

import Storage

/// Adapter that bridges SelectionStorage's Combine interface to SwiftUI's ObservableObject pattern
///
/// This adapter converts any SelectionStorage implementation into a SwiftUI-compatible observable object
/// by mapping the Combine publisher to a @Published property that can be directly observed in SwiftUI views.
///
/// ## Purpose
/// Enables SwiftUI views to use any SelectionStorage implementation without requiring
/// direct Combine publisher handling or manual state management.
///
/// ## Usage
/// ```swift
/// @StateObject var selectionStorage = ObservableSelectionStorage(
///     storage: DefaultSelectionStorage()
/// )
/// ```
///
/// - Important: Automatically handles main thread dispatching for UI updates
/// - Note: Pure adapter pattern - forwards all calls to underlying storage without modification
final class ObservableSelectionStorage: ObservableObject {

    /// The current selection state adapted for SwiftUI observation
    @Published private(set) var selections: [String] = []

    private let storage: SelectionStorage
    private var cancellables = Set<AnyCancellable>()

    /// Creates a SwiftUI adapter for SelectionStorage
    /// - Parameter storage: The Combine-based storage implementation to adapt
    init(storage: SelectionStorage) {
        self.storage = storage
        self.selections = storage.selections

        storage.selectionsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$selections)
    }

    /// Forwards selection toggling to adapted storage
    func toggleSelection(for source: Source) {
        storage.toggleSelection(for: source)
    }

    /// Forwards selection checks to adapted storage
    func isSelected(_ source: Source) -> Bool {
        storage.isSelected(source)
    }
}
