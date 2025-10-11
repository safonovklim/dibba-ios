//
//  Report.swift
//  Core
//
//  Created by Klim on 10/11/25.
//
import Foundation

public struct Report: Identifiable, Codable, Sendable, Equatable, Hashable {
    public var id: String
    public var cards: [String: String]
    public var counts: [String: String]
    public var merchantCategories: [String: String]
    public var orgNames: [String: String]
    public var sums: [String: ReportSum]
    public var isCurrent: Bool
    
    public init(
        id: String,
        cards: [String : String],
        counts: [String : String],
        merchantCategories: [String : String],
        orgNames: [String : String],
        sums: [String : ReportSum],
        isCurrent: Bool
    ) {
        self.id = id
        self.cards = cards
        self.counts = counts
        self.merchantCategories = merchantCategories
        self.orgNames = orgNames
        self.sums = sums
        self.isCurrent = isCurrent
    }
}
