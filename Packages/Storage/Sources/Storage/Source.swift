//
//  Source.swift
//  Storage
//
//  Created by Eduardo Dias on 31/08/2025.
//

public struct Source: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let url: String
    public let category: String
    public let language: String
    public let country: String
}
