import Foundation
import Testing

@testable import RestClient

@Suite("Serializer Tests")
struct SerializerTests {

    // MARK: - DefaultSerializer Tests

    @Test("serialization of simple struct")
    func serializationOfSimpleStruct() throws {
        let serializer = DefaultSerializer()
        let testData = TestRequest(name: "John", value: 42)

        let data = try serializer.serialize(testData)

        #expect(data.count > 0)

        // Verify the serialized data can be deserialized back
        let deserializedData = try JSONDecoder().decode(TestRequest.self, from: data)
        #expect(deserializedData.name == "John")
        #expect(deserializedData.value == 42)
    }

    @Test("deserialization of simple struct")
    func deserializationOfSimpleStruct() throws {
        let serializer = DefaultSerializer()
        let originalData = TestResponse(id: 123, message: "Success")
        let jsonData = try JSONEncoder().encode(originalData)

        let result = try serializer.deserialize(TestResponse.self, data: jsonData)

        #expect(result.id == 123)
        #expect(result.message == "Success")
    }

    @Test("serialization of complex nested struct")
    func serializationOfComplexNestedStruct() throws {
        let serializer = DefaultSerializer()
        let complexData = ComplexTestData(
            user: UserData(id: 1, name: "Alice", email: "alice@example.com"),
            metadata: ["key1": "value1", "key2": "value2"],
            tags: ["important", "urgent"],
            isActive: true
        )

        let data = try serializer.serialize(complexData)

        #expect(data.count > 0)

        // Verify the serialized data structure
        let deserializedData = try JSONDecoder().decode(ComplexTestData.self, from: data)
        #expect(deserializedData.user.name == "Alice")
        #expect(deserializedData.metadata["key1"] == "value1")
        #expect(deserializedData.tags.count == 2)
        #expect(deserializedData.isActive == true)
    }

    @Test("deserialization of complex nested struct")
    func deserializationOfComplexNestedStruct() throws {
        let serializer = DefaultSerializer()
        let complexData = ComplexTestData(
            user: UserData(id: 2, name: "Bob", email: "bob@example.com"),
            metadata: ["type": "admin"],
            tags: ["verified"],
            isActive: false
        )
        let jsonData = try JSONEncoder().encode(complexData)

        let result = try serializer.deserialize(ComplexTestData.self, data: jsonData)

        #expect(result.user.id == 2)
        #expect(result.user.name == "Bob")
        #expect(result.user.email == "bob@example.com")
        #expect(result.metadata["type"] == "admin")
        #expect(result.tags == ["verified"])
        #expect(result.isActive == false)
    }

    @Test("serialization of array")
    func serializationOfArray() throws {
        let serializer = DefaultSerializer()
        let arrayData = [
            TestResponse(id: 1, message: "First"),
            TestResponse(id: 2, message: "Second"),
            TestResponse(id: 3, message: "Third")
        ]

        let data = try serializer.serialize(arrayData)

        #expect(data.count > 0)

        // Verify the serialized array
        let deserializedArray = try JSONDecoder().decode([TestResponse].self, from: data)
        #expect(deserializedArray.count == 3)
        #expect(deserializedArray[0].message == "First")
        #expect(deserializedArray[2].message == "Third")
    }

    @Test("deserialization of array")
    func deserializationOfArray() throws {
        let serializer = DefaultSerializer()
        let arrayData = [
            TestRequest(name: "Item1", value: 10),
            TestRequest(name: "Item2", value: 20)
        ]
        let jsonData = try JSONEncoder().encode(arrayData)

        let result = try serializer.deserialize([TestRequest].self, data: jsonData)

        #expect(result.count == 2)
        #expect(result[0].name == "Item1")
        #expect(result[0].value == 10)
        #expect(result[1].name == "Item2")
        #expect(result[1].value == 20)
    }

    @Test("serialization of optional fields")
    func serializationOfOptionalFields() throws {
        let serializer = DefaultSerializer()
        let optionalData = OptionalTestData(
            requiredField: "Required",
            optionalField: "Optional",
            nilField: nil
        )

        let data = try serializer.serialize(optionalData)

        #expect(data.count > 0)

        // Verify optional fields handling
        let deserializedData = try JSONDecoder().decode(OptionalTestData.self, from: data)
        #expect(deserializedData.requiredField == "Required")
        #expect(deserializedData.optionalField == "Optional")
        #expect(deserializedData.nilField == nil)
    }

    @Test("deserialization of optional fields")
    func deserializationOfOptionalFields() throws {
        let serializer = DefaultSerializer()
        let optionalData = OptionalTestData(
            requiredField: "Test",
            optionalField: nil,
            nilField: nil
        )
        let jsonData = try JSONEncoder().encode(optionalData)

        let result = try serializer.deserialize(OptionalTestData.self, data: jsonData)

        #expect(result.requiredField == "Test")
        #expect(result.optionalField == nil)
        #expect(result.nilField == nil)
    }

    @Test("serialization with custom encoder")
    func serializationWithCustomEncoder() throws {
        let customEncoder = JSONEncoder()
        customEncoder.outputFormatting = .prettyPrinted
        let serializer = DefaultSerializer(dataEncoder: customEncoder)
        let testData = TestRequest(name: "Custom", value: 99)

        let data = try serializer.serialize(testData)

        #expect(data.count > 0)

        // Verify it's pretty printed (contains newlines and spaces)
        let jsonString = String(data: data, encoding: .utf8)!
        #expect(jsonString.contains("\n"))
    }

    @Test("deserialization with custom decoder")
    func deserializationWithCustomDecoder() throws {
        let customDecoder = JSONDecoder()
        customDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let serializer = DefaultSerializer(dataDecoder: customDecoder)

        // JSON with snake_case keys
        let snakeCaseJSON = """
        {
            "user_name": "Snake Case",
            "user_id": 456
        }
        """.data(using: .utf8)!

        let result = try serializer.deserialize(SnakeCaseTestData.self, data: snakeCaseJSON)

        #expect(result.userName == "Snake Case")
        #expect(result.userId == 456)
    }

    // MARK: - Error Handling Tests

    @Test("serialization throws error for non encodable type")
    func serializationThrowsErrorForNonEncodableType() throws {
        let mockEncoder = MockDataEncoderWithError()
        let serializerWithMockEncoder = DefaultSerializer(dataEncoder: mockEncoder)
        let testData = TestRequest(name: "Error", value: 1)

        #expect(throws: MockEncodingError.self) {
            try serializerWithMockEncoder.serialize(testData)
        }
    }

    @Test("deserialization throws error for invalid JSON")
    func deserializationThrowsErrorForInvalidJson() throws {
        let serializer = DefaultSerializer()
        let invalidJSON = "{ invalid json }".data(using: .utf8)!

        #expect(throws: DecodingError.self) {
            try serializer.deserialize(TestResponse.self, data: invalidJSON)
        }
    }

    @Test("deserialization throws error for mismatched type")
    func deserializationThrowsErrorForMismatchedType() throws {
        let serializer = DefaultSerializer()
        let stringData = try JSONEncoder().encode("This is a string")

        #expect(throws: DecodingError.self) {
            try serializer.deserialize(TestResponse.self, data: stringData)
        }
    }

    @Test("deserialization throws error for missing required fields")
    func deserializationThrowsErrorForMissingRequiredFields() throws {
        let serializer = DefaultSerializer()
        let incompleteJSON = """
        {
            "name": "Missing value field"
        }
        """.data(using: .utf8)!

        #expect(throws: DecodingError.self) {
            try serializer.deserialize(TestRequest.self, data: incompleteJSON)
        }
    }

    @Test("serialization propagates encoder errors")
    func serializationPropagatesEncoderErrors() throws {
        let mockEncoder = MockDataEncoderWithError()
        let serializer = DefaultSerializer(dataEncoder: mockEncoder)
        let testData = TestRequest(name: "Test", value: 1)

        #expect(throws: MockEncodingError.self) {
            try serializer.serialize(testData)
        }
    }

    @Test("deserialization propagates decoder errors")
    func deserializationPropagatesDecoderErrors() throws {
        let mockDecoder = MockDataDecoderWithError()
        let serializer = DefaultSerializer(dataDecoder: mockDecoder)
        let validJSON = try JSONEncoder().encode(TestResponse(id: 1, message: "Test"))

        #expect(throws: MockDecodingError.self) {
            try serializer.deserialize(TestResponse.self, data: validJSON)
        }
    }

    // MARK: - Edge Cases Tests

    @Test("serialization handles empty struct")
    func serializationHandlesEmptyStruct() throws {
        let serializer = DefaultSerializer()
        let emptyData = EmptyTestData()

        let data = try serializer.serialize(emptyData)

        #expect(data.count > 0)

        // Should be valid empty JSON object
        let jsonString = String(data: data, encoding: .utf8)!
        #expect(jsonString.contains("{}"))
    }

    @Test("deserialization handles empty JSON object")
    func deserializationHandlesEmptyJsonObject() throws {
        let serializer = DefaultSerializer()
        let emptyJSON = "{}".data(using: .utf8)!

        let result = try serializer.deserialize(EmptyTestData.self, data: emptyJSON)

        // Should successfully create empty struct
        #expect(result != nil)
    }

    @Test("serialization handles large data")
    func serializationHandlesLargeData() throws {
        let serializer = DefaultSerializer()
        let largeArray = Array(0 ..< 1000).map { TestRequest(name: "Item \($0)", value: $0) }

        let data = try serializer.serialize(largeArray)

        #expect(data.count > 0)

        // Verify it can be deserialized
        let deserializedArray = try JSONDecoder().decode([TestRequest].self, from: data)
        #expect(deserializedArray.count == 1000)
        #expect(deserializedArray.last?.name == "Item 999")
    }

    @Test("round trip serialization maintains data integrity")
    func roundTripSerializationMaintainsDataIntegrity() throws {
        let serializer = DefaultSerializer()
        let originalData = ComplexTestData(
            user: UserData(id: 999, name: "Round Trip", email: "test@roundtrip.com"),
            metadata: ["test": "value", "number": "42"],
            tags: ["serialization", "test", "round-trip"],
            isActive: true
        )

        let serializedData = try serializer.serialize(originalData)
        let deserializedData = try serializer.deserialize(ComplexTestData.self, data: serializedData)

        #expect(deserializedData.user.id == originalData.user.id)
        #expect(deserializedData.user.name == originalData.user.name)
        #expect(deserializedData.user.email == originalData.user.email)
        #expect(deserializedData.metadata == originalData.metadata)
        #expect(deserializedData.tags == originalData.tags)
        #expect(deserializedData.isActive == originalData.isActive)
    }

    // MARK: - Mock Classes

    private enum MockEncodingError: Error {
        case encodingFailed
    }

    private class MockDataEncoderWithError: DataEncoder {
        func encode(_: some Encodable) throws -> Data {
            throw MockEncodingError.encodingFailed
        }
    }

    private enum MockDecodingError: Error {
        case decodingFailed
    }

    private class MockDataDecoderWithError: DataDecoder {
        func decode<T>(_: T.Type, from _: Data) throws -> T where T: Decodable {
            throw MockDecodingError.decodingFailed
        }
    }
}

// MARK: - Test Models

private struct TestRequest: Codable {
    let name: String
    let value: Int
}

private struct TestResponse: Codable {
    let id: Int
    let message: String
}

private struct UserData: Codable {
    let id: Int
    let name: String
    let email: String
}

private struct ComplexTestData: Codable {
    let user: UserData
    let metadata: [String: String]
    let tags: [String]
    let isActive: Bool
}

private struct OptionalTestData: Codable {
    let requiredField: String
    let optionalField: String?
    let nilField: String?
}

private struct EmptyTestData: Codable {
    // Empty struct for testing
}

private struct SnakeCaseTestData: Codable {
    let userName: String
    let userId: Int
}
