import Combine
import Foundation

/// Handles storage and observation of selected identifiers
public protocol SelectionStorage: AnyObject {
    /// Current selected IDs
    var selections: [String] { get }

    /// Publisher for selection changes
    var selectionsPublisher: AnyPublisher<[String], Never> { get }

    /// Toggles selection for a source
    func toggleSelection(for source: Source)

    /// Checks if source is selected
    func isSelected(_ source: Source) -> Bool
}

/// Persists selections in UserDefaults and publishes changes.
/// Automatically loads saved selections on initialization.
public final class DefaultSelectionStorage: SelectionStorage {

    /// Current selections (private set)
    private(set) public var selections: [String] = [] {
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
        self.selections = defaults.stringArray(forKey: key) ?? []
        subject.send(saved)
    }

    /// Toggles selection and saves to UserDefaults
    public func toggleSelection(for source: Source) {
        if selections.contains(source.id) {
            selections.removeAll { $0 == source.id }
        } else {
            selections.append(source.id)
        }
        defaults.set(selections, forKey: key)
    }

    /// Checks if source is selected
    public func isSelected(_ source: Source) -> Bool {
        selections.contains(source.id)
    }
}
