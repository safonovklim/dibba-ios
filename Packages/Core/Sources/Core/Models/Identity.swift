//
//  Identity.swift
//  Core
//
//  Created by Klim on 10/11/25.
//
import Foundation


public struct Identity: Identifiable, Codable, Sendable, Equatable, Hashable {
    public var id: String
    public var name: String
    public var email: String
    public var platform: String
    public var createdAt: Date
    
    public init(id: String, name: String, email: String, platform: String, createdAt: Date) {
        self.id = id
        self.name = name
        self.email = email
        self.platform = platform
        self.createdAt = createdAt
    }
}

