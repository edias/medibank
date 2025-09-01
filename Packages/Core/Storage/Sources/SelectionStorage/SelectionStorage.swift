import Combine
import Foundation

/// Handles storage and observation of selected identifiers
public protocol SelectionStorage: AnyObject {
    /// Current selected IDs
    var selections: [String] { get }

    /// Publisher for selection changes
    var selectionsPublisher: AnyPublisher<[String], Never> { get }

    /// Toggles selection for a source
    func toggleSelection(for sourceId: String)

    /// Checks if source is selected
    func isSelected(_ sourceId: String) -> Bool
}

/// Persists selections in UserDefaults and publishes changes.
/// Automatically loads saved selections on initialization.
public final class DefaultSelectionStorage: SelectionStorage {

    /// Current selections (private set)
    public private(set) var selections: [String] = [] {
        didSet { subject.send(selections) }
    }

    private let key = "selectedSourcesIds"
    private let defaults: UserDefaults
    private let subject = CurrentValueSubject<[String], Never>([])

    /// Publisher for selection changes
    public var selectionsPublisher: AnyPublisher<[String], Never> {
        subject.eraseToAnyPublisher()
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let saved = defaults.stringArray(forKey: key) ?? []
        selections = defaults.stringArray(forKey: key) ?? []
        subject.send(saved)
    }

    /// Toggles selection and saves to UserDefaults
    public func toggleSelection(for sourceId: String) {
        if selections.contains(sourceId) {
            selections.removeAll { $0 == sourceId }
        } else {
            selections.append(sourceId)
        }
        updateStorage()
    }

    /// Checks if source is selected
    public func isSelected(_ sourceId: String) -> Bool {
        selections.contains(sourceId)
    }

    private func updateStorage() {
        defaults.set(selections, forKey: key)
        defaults.synchronize()
    }
}
