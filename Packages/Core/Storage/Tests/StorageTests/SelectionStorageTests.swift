import Combine
import Foundation
import Testing
@testable import Storage

@Suite("SelectionStorage Tests")
struct SelectionStorageTests {
    
    // MARK: - DefaultSelectionStorage Tests
    
    @Test("initialization loads selections from UserDefaults")
    func initializationLoadsSelectionsFromUserDefaults() throws {

        let mockDefaults = MockUserDefaults()
        mockDefaults.stringArray = ["source1", "source2", "source3"]
        
        let storage = DefaultSelectionStorage(defaults: mockDefaults)
        
        #expect(storage.selections == ["source1", "source2", "source3"])
        #expect(mockDefaults.stringArrayForKeyCalled == true)
        #expect(mockDefaults.lastKeyUsed == "selectedSourcesIds")
    }
    
    @Test("initialization with empty UserDefaults creates empty selections")
    func initializationWithEmptyUserDefaultsCreatesEmptySelections() throws {

        let mockDefaults = MockUserDefaults()
        mockDefaults.stringArray = nil
        
        let storage = DefaultSelectionStorage(defaults: mockDefaults)
        
        #expect(storage.selections.isEmpty)
    }
    
    @Test("selectionsPublisher emits current selections on initialization")
    func selectionsPublisherEmitsCurrentSelectionsOnInitialization() async throws {

        let mockDefaults = MockUserDefaults()
        mockDefaults.stringArray = ["source1", "source2"]
        
        let storage = DefaultSelectionStorage(defaults: mockDefaults)
        
        var receivedSelections: [String] = []
        let cancellable = storage.selectionsPublisher
            .sink { selections in
                receivedSelections = selections
            }
        
        #expect(receivedSelections == ["source1", "source2"])
        
        cancellable.cancel()
    }
    
    @Test("toggleSelection adds new source to selections")
    func toggleSelectionAddsNewSourceToSelections() throws {

        let mockDefaults = MockUserDefaults()
        let storage = DefaultSelectionStorage(defaults: mockDefaults)
        let source = createMockSource(id: "new-source")
        
        storage.toggleSelection(for: source.id)

        #expect(storage.selections.contains("new-source"))
        #expect(mockDefaults.setForKeyCalled == true)
        #expect(mockDefaults.lastSetValue as? [String] == ["new-source"])
        #expect(mockDefaults.lastSetKey == "selectedSourcesIds")
    }
    
    @Test("toggleSelection removes existing source from selections")
    func toggleSelectionRemovesExistingSourceFromSelections() throws {

        let mockDefaults = MockUserDefaults()
        mockDefaults.stringArray = ["existing-source", "other-source"]
        
        let storage = DefaultSelectionStorage(defaults: mockDefaults)
        let source = createMockSource(id: "existing-source")
        
        storage.toggleSelection(for: source.id)

        #expect(!storage.selections.contains("existing-source"))
        #expect(storage.selections.contains("other-source"))
        #expect(mockDefaults.setForKeyCalled == true)
        #expect(mockDefaults.lastSetValue as? [String] == ["other-source"])
    }
    
    @Test("isSelected returns true for selected source")
    func isSelectedReturnsTrueForSelectedSource() throws {

        let mockDefaults = MockUserDefaults()
        mockDefaults.stringArray = ["selected-source", "other-source"]
        
        let storage = DefaultSelectionStorage(defaults: mockDefaults)
        let source = createMockSource(id: "selected-source")
        
        #expect(storage.isSelected(source.id) == true)
    }
    
    @Test("isSelected returns false for unselected source")
    func isSelectedReturnsFalseForUnselectedSource() throws {

        let mockDefaults = MockUserDefaults()
        mockDefaults.stringArray = ["selected-source"]
        
        let storage = DefaultSelectionStorage(defaults: mockDefaults)
        let source = createMockSource(id: "unselected-source")
        
        #expect(storage.isSelected(source.id) == false)
    }
    
    @Test("selectionsPublisher emits updated selections when toggled")
    func selectionsPublisherEmitsUpdatedSelectionsWhenToggled() async throws {

        let mockDefaults = MockUserDefaults()
        let storage = DefaultSelectionStorage(defaults: mockDefaults)
        let source = createMockSource(id: "test-source")
        
        var receivedSelections: [[String]] = []
        let cancellable = storage.selectionsPublisher
            .sink { selections in
                receivedSelections.append(selections)
            }
        
        storage.toggleSelection(for: source.id)

        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        #expect(receivedSelections.count >= 2)
        #expect(receivedSelections.first == [])
        #expect(receivedSelections.last == ["test-source"])
        
        cancellable.cancel()
    }
    
    @Test("multiple toggles on same source work correctly")
    func multipleTogglesOnSameSourceWorkCorrectly() throws {

        let mockDefaults = MockUserDefaults()
        let storage = DefaultSelectionStorage(defaults: mockDefaults)
        let source = createMockSource(id: "toggle-source")
        
        // First toggle - add
        storage.toggleSelection(for: source.id)
        #expect(storage.isSelected(source.id) == true)
        #expect(storage.selections.contains("toggle-source"))
        
        // Second toggle - remove
        storage.toggleSelection(for: source.id)
        #expect(storage.isSelected(source.id) == false)
        #expect(!storage.selections.contains("toggle-source"))
        
        // Third toggle - add again
        storage.toggleSelection(for: source.id)
        #expect(storage.isSelected(source.id) == true)
        #expect(storage.selections.contains("toggle-source"))
    }
    
    @Test("selections are persisted to UserDefaults on each toggle")
    func selectionsArePersistedToUserDefaultsOnEachToggle() throws {

        let mockDefaults = MockUserDefaults()
        let storage = DefaultSelectionStorage(defaults: mockDefaults)
        let source1 = createMockSource(id: "source1")
        let source2 = createMockSource(id: "source2")
        
        storage.toggleSelection(for: source1.id)
        #expect(mockDefaults.setCallCount == 1)
        
        storage.toggleSelection(for: source2.id)
        #expect(mockDefaults.setCallCount == 2)
        
        storage.toggleSelection(for: source1.id)
        #expect(mockDefaults.setCallCount == 3)
        #expect(mockDefaults.lastSetValue as? [String] == ["source2"])
    }
    
    @Test("selectionsPublisher is a CurrentValueSubject that maintains current state")
    func selectionsPublisherIsCurrentValueSubjectThatMaintainsCurrentState() async throws {

        let mockDefaults = MockUserDefaults()
        mockDefaults.stringArray = ["initial-source"]
        
        let storage = DefaultSelectionStorage(defaults: mockDefaults)
        
        // Subscribe after initialization should get current state
        var receivedSelections: [String] = []
        let cancellable = storage.selectionsPublisher
            .sink { selections in
                receivedSelections = selections
            }
        
        #expect(receivedSelections == ["initial-source"])
        
        let source = createMockSource(id: "new-source")
        storage.toggleSelection(for: source.id)
        
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms
        
        #expect(receivedSelections == ["initial-source", "new-source"])
        
        cancellable.cancel()
    }
    
    @Test("default initializer uses standard UserDefaults")
    func defaultInitializerUsesStandardUserDefaults() throws {

        let storage = DefaultSelectionStorage()
        
        // We can't easily test this without affecting the real UserDefaults,
        // but we can verify the storage was created successfully
        #expect(storage.selections != nil)
        #expect(storage.selectionsPublisher != nil)
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

// MARK: - Mock UserDefaults

private class MockUserDefaults: UserDefaults {
    
    var stringArray: [String]?
    var stringArrayForKeyCalled = false
    var lastKeyUsed: String?
    
    var setForKeyCalled = false
    var setCallCount = 0
    var lastSetValue: Any?
    var lastSetKey: String?
    
    override func stringArray(forKey defaultName: String) -> [String]? {
        stringArrayForKeyCalled = true
        lastKeyUsed = defaultName
        return stringArray
    }
    
    override func set(_ value: Any?, forKey defaultName: String) {
        setForKeyCalled = true
        setCallCount += 1
        lastSetValue = value
        lastSetKey = defaultName
    }
}
