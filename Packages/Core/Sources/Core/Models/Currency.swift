//
//  Currency.swift
//  Core
//
//  Created by Klim on 10/11/25.
//
import Foundation

public struct Currency: Identifiable, Codable, Sendable, Equatable, Hashable {
    public var id: String
    public var label: String
    public var emoji: String
    public var continent: String
    public var timezones: [String]
    
    public init(id: String, label: String, emoji: String, continent: String, timezones: [String]) {
        self.id = id
        self.label = label
        self.emoji = emoji
        self.continent = continent
        self.timezones = timezones
    }
}
