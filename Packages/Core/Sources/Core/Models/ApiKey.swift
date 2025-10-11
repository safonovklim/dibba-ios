//
//  ApiKey.swift
//  Core
//
//  Created by Klim on 10/11/25.
//
import Foundation

public struct ApiKey: Identifiable, Codable, Sendable, Equatable, Hashable {
    public var id: String
    public var name: String
    public var active: Bool
    public var createdAt: Date
    public var createdAtISO: String
    
    public init(id: String, name: String, active: Bool, createdAt: Date, createdAtISO: String) {
        self.id = id
        self.name = name
        self.active = active
        self.createdAt = createdAt
        self.createdAtISO = createdAtISO
    }
}
