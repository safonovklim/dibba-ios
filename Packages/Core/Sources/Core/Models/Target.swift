//
//  Target.swift
//  Core
//
//  Created by Klim on 10/11/25.
//

import Foundation

public enum TargetStrategy: String, Codable, Sendable {
    case fixedAmountWeekly = "FIXED_AMOUNT_WEEKLY"
    case fixedAmountMonthly = "FIXED_AMOUNT_MONTHLY"
    case fixedIncomePercent = "FIXED_INCOME_PERCENT"
    case open = "OPEN"
}

public struct Target: Identifiable, Codable, Sendable, Equatable, Hashable {
    public var id: String
    public var userId: String
    public var emoji: String
    public var name: String
    public var strategy: TargetStrategy
    public var currency: String
    public var amountSaved: Decimal
    public var amountTarget: Decimal
    public var expectedStartAt: Date
    public var expectedEndAt: Date
    public var remindWeekly: Bool
    public var remindMonthly: Bool
    public var completed: Bool
    public var archived: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String,
        userId: String,
        emoji: String,
        name: String,
        strategy: TargetStrategy,
        currency: String,
        amountSaved: Decimal,
        amountTarget: Decimal,
        expectedStartAt: Date,
        expectedEndAt: Date,
        remindWeekly: Bool,
        remindMonthly: Bool,
        completed: Bool,
        archived: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.userId = userId
        self.emoji = emoji
        self.name = name
        self.strategy = strategy
        self.currency = currency
        self.amountSaved = amountSaved
        self.amountTarget = amountTarget
        self.expectedStartAt = expectedStartAt
        self.expectedEndAt = expectedEndAt
        self.remindWeekly = remindWeekly
        self.remindMonthly = remindMonthly
        self.completed = completed
        self.archived = archived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

