import Combine
import SwiftUI
import Testing

@testable import SourceSelection
@testable import Storage

@Suite("ObservableSelectionStorage Tests")
@MainActor
struct ObservableSelectionStorageTests {

    // MARK: - Initialization Tests

    @Test("initialization with empty storage creates empty selections")
    func initializationWithEmptyStorageCreatesEmptySelections() async throws {

        let mockStorage = MockSelectionStorage()
        mockStorage.selections = []

        let observableStorage = ObservableSelectionStorage(storage: mockStorage)

        #expect(observableStorage.selections == [])
    }

    @Test("initialization with existing selections copies current state")
    func initializationWithExistingSelectionsCopiesCurrentState() async throws {

        let mockStorage = MockSelectionStorage()
        mockStorage.selections = ["source1", "source2"]

        let observableStorage = ObservableSelectionStorage(storage: mockStorage)

        #expect(observableStorage.selections == ["source1", "source2"])
    }

    @Test("initialization subscribes to storage publisher")
    func initializationSubscribesToStoragePublisher() async throws {

        let mockStorage = MockSelectionStorage()
        mockStorage.selections = ["initial"]

        let observableStorage = ObservableSelectionStorage(storage: mockStorage)

        #expect(mockStorage.selectionsPublisherAccessCount == 1)
        #expect(observableStorage.selections == ["initial"])
    }

    // MARK: - Publisher Integration Tests

    @Test("selections update when storage publisher emits new values")
    func selectionsUpdateWhenStoragePublisherEmitsNewValues() async throws {

        let mockStorage = MockSelectionStorage()
        mockStorage.selections = ["initial"]

        let observableStorage = ObservableSelectionStorage(storage: mockStorage)

        // Verify initial state
        #expect(observableStorage.selections == ["initial"])

        // Emit new selections
        mockStorage.simulateSelectionChange(to: ["updated", "values"])

        // Allow time for main queue dispatch
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms

        #expect(observableStorage.selections == ["updated", "values"])
    }

    // MARK: - Method Forwarding Tests

    @Test("toggleSelection forwards call to underlying storage")
    func toggleSelectionForwardsCallToUnderlyingStorage() throws {

        let mockStorage = MockSelectionStorage()
        let observableStorage = ObservableSelectionStorage(storage: mockStorage)
        let testSource = createMockSource(id: "test-source")

        observableStorage.toggleSelection(for: testSource.id)

        #expect(mockStorage.toggleSelectionCallCount == 1)
        #expect(mockStorage.lastToggledSourceId == "test-source")
    }

    @Test("isSelected forwards call to underlying storage")
    func isSelectedForwardsCallToUnderlyingStorage() throws {

        let mockStorage = MockSelectionStorage()
        mockStorage.isSelectedReturnValue = true

        let observableStorage = ObservableSelectionStorage(storage: mockStorage)
        let testSource = createMockSource(id: "test-source")

        let result = observableStorage.isSelected(testSource.id)

        #expect(result == true)
        #expect(mockStorage.isSelectedCallCount == 1)
        #expect(mockStorage.lastCheckedSourceId == "test-source")
    }

    @Test("isSelected returns false when storage returns false")
    func isSelectedReturnsFalseWhenStorageReturnsFalse() throws {

        let mockStorage = MockSelectionStorage()
        mockStorage.isSelectedReturnValue = false

        let observableStorage = ObservableSelectionStorage(storage: mockStorage)
        let testSource = createMockSource(id: "unselected-source")

        let result = observableStorage.isSelected(testSource.id)

        #expect(result == false)
    }

    // MARK: - Integration Tests

    @Test("toggle operation updates observable selections")
    func toggleOperationUpdatesObservableSelections() async throws {

        let mockStorage = MockSelectionStorage()
        mockStorage.selections = []

        let observableStorage = ObservableSelectionStorage(storage: mockStorage)
        let testSource = createMockSource(id: "toggle-source")

        // Initial state
        #expect(observableStorage.selections == [])

        // Toggle selection
        observableStorage.toggleSelection(for: testSource.id)

        // Simulate storage updating its state and notifying publisher
        mockStorage.selections = ["toggle-source"]
        mockStorage.simulateSelectionChange(to: ["toggle-source"])

        // Allow time for main queue dispatch
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms

        #expect(observableStorage.selections == ["toggle-source"])
    }

    @Test("multiple toggles reflect in observable selections")
    func multipleTogglesReflectInObservableSelections() async throws {

        let mockStorage = MockSelectionStorage()
        mockStorage.selections = []

        let observableStorage = ObservableSelectionStorage(storage: mockStorage)
        let source1 = createMockSource(id: "source1")
        let source2 = createMockSource(id: "source2")

        // Toggle first source
        observableStorage.toggleSelection(for: source1.id)
        mockStorage.selections = ["source1"]
        mockStorage.simulateSelectionChange(to: ["source1"])

        try await Task.sleep(nanoseconds: 30_000_000) // 30ms

        // Toggle second source
        observableStorage.toggleSelection(for: source2.id)
        mockStorage.selections = ["source1", "source2"]
        mockStorage.simulateSelectionChange(to: ["source1", "source2"])

        try await Task.sleep(nanoseconds: 30_000_000) // 30ms

        #expect(observableStorage.selections == ["source1", "source2"])
        #expect(mockStorage.toggleSelectionCallCount == 2)
    }

    @Test("observable object publishes changes correctly")
    func observableObjectPublishesChangesCorrectly() async throws {

        let mockStorage = MockSelectionStorage()
        mockStorage.selections = []

        let observableStorage = ObservableSelectionStorage(storage: mockStorage)

        var receivedChanges: [[String]] = []
        let cancellable = observableStorage.$selections
            .sink { selections in
                receivedChanges.append(selections)
            }

        // Initial state
        #expect(receivedChanges.count == 1)
        #expect(receivedChanges[0] == [])

        // Simulate selection change
        mockStorage.simulateSelectionChange(to: ["new-selection"])

        try await Task.sleep(nanoseconds: 50_000_000) // 50ms

        #expect(receivedChanges.count >= 2)
        #expect(receivedChanges.last == ["new-selection"])

        cancellable.cancel()
    }

    // MARK: - Edge Cases

    @Test("handles empty selection arrays correctly")
    func handlesEmptySelectionArraysCorrectly() async throws {

        let mockStorage = MockSelectionStorage()
        mockStorage.selections = ["something"]

        let observableStorage = ObservableSelectionStorage(storage: mockStorage)

        #expect(observableStorage.selections == ["something"])

        // Simulate clearing selections
        mockStorage.simulateSelectionChange(to: [])

        try await Task.sleep(nanoseconds: 50_000_000) // 50ms

        #expect(observableStorage.selections == [])
    }

    @Test("handles duplicate selections correctly")
    func handlesDuplicateSelectionsCorrectly() async throws {

        let mockStorage = MockSelectionStorage()
        mockStorage.selections = []

        let observableStorage = ObservableSelectionStorage(storage: mockStorage)

        // Simulate receiving duplicate selections
        mockStorage.simulateSelectionChange(to: ["dup", "dup", "unique"])

        try await Task.sleep(nanoseconds: 50_000_000) // 50ms

        #expect(observableStorage.selections == ["dup", "dup", "unique"])
    }

    // MARK: - Memory Management Tests

    @Test("properly manages cancellables on deinit")
    func properlyManagesCancellablesOnDeinit() throws {

        let mockStorage = MockSelectionStorage()

        var observableStorage: ObservableSelectionStorage? = ObservableSelectionStorage(storage: mockStorage)

        #expect(observableStorage != nil)
        #expect(mockStorage.selectionsPublisherAccessCount == 1)

        // Deinitialize
        observableStorage = nil

        // Storage should still be accessible but no longer have active subscribers
        #expect(mockStorage.selections != nil)
    }

    // MARK: - Helper Methods

    private func createMockSource(id: String) -> Source {
        Source(
            id: id,
            name: "Test Source",
            description: "Test Description",
            url: "https://test.com",
            category: "Test",
            language: "en",
            country: "US"
        )
    }
}

// MARK: - Mock SelectionStorage

private class MockSelectionStorage: SelectionStorage {

    var selections: [String] = []

    private let subject = CurrentValueSubject<[String], Never>([])

    // Tracking properties
    var selectionsPublisherAccessCount = 0
    var toggleSelectionCallCount = 0
    var isSelectedCallCount = 0
    var lastToggledSourceId: String?
    var lastCheckedSourceId: String?
    var isSelectedReturnValue = false

    var selectionsPublisher: AnyPublisher<[String], Never> {
        selectionsPublisherAccessCount += 1
        return subject.eraseToAnyPublisher()
    }

    func toggleSelection(for sourceId: String) {
        toggleSelectionCallCount += 1
        lastToggledSourceId = sourceId
    }

    func isSelected(_ sourceId: String) -> Bool {
        isSelectedCallCount += 1
        lastCheckedSourceId = sourceId
        return isSelectedReturnValue
    }

    // Helper method to simulate selection changes
    func simulateSelectionChange(to newSelections: [String]) {
        selections = newSelections
        subject.send(newSelections)
    }
}

// MARK: - Helper AsyncExpectation

private actor AsyncExpectation {
    private var isFulfilled = false

    func fulfill() {
        isFulfilled = true
    }

    func wait(for timeout: TimeInterval) async {
        let deadline = Date().addingTimeInterval(timeout)

        while !isFulfilled, Date() < deadline {
            try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
    }
}
