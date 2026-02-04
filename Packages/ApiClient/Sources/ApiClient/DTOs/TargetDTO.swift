import Foundation

// MARK: - Target DTO

public struct TargetDTO: Codable, Sendable {
    public let id: String
    public let name: String
    public let emoji: String?
    public let strategy: String?
    public let currency: String?
    public let amountSaved: Double?
    public let amountTarget: Double?
    public let expectedStartAt: Date?
    public let expectedEndAt: Date?
    public let remindWeekly: Bool?
    public let remindMonthly: Bool?
    public let completed: Bool?
    public let archived: Bool?
    public let createdAt: Date?
    public let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, emoji, strategy, currency, completed, archived
        case amountSaved = "amount_saved"
        case amountTarget = "amount_target"
        case expectedStartAt = "expected_start_at"
        case expectedEndAt = "expected_end_at"
        case remindWeekly = "remind_weekly"
        case remindMonthly = "remind_monthly"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - List Targets Response

public struct ListTargetsResponse: Codable, Sendable {
    public let listTargets: [TargetDTO]
}

// MARK: - Create Target

public struct CreateTargetInput: Encodable, Sendable {
    public let name: String
    public let emoji: String?
    public let strategy: String?
    public let currency: String?
    public let amountTarget: Double?
    public let expectedStartAt: Date?
    public let expectedEndAt: Date?
    public let remindWeekly: Bool?
    public let remindMonthly: Bool?

    public init(
        name: String,
        emoji: String? = nil,
        strategy: String? = nil,
        currency: String? = nil,
        amountTarget: Double? = nil,
        expectedStartAt: Date? = nil,
        expectedEndAt: Date? = nil,
        remindWeekly: Bool? = nil,
        remindMonthly: Bool? = nil
    ) {
        self.name = name
        self.emoji = emoji
        self.strategy = strategy
        self.currency = currency
        self.amountTarget = amountTarget
        self.expectedStartAt = expectedStartAt
        self.expectedEndAt = expectedEndAt
        self.remindWeekly = remindWeekly
        self.remindMonthly = remindMonthly
    }

    enum CodingKeys: String, CodingKey {
        case name, emoji, strategy, currency
        case amountTarget = "amount_target"
        case expectedStartAt = "expected_start_at"
        case expectedEndAt = "expected_end_at"
        case remindWeekly = "remind_weekly"
        case remindMonthly = "remind_monthly"
    }
}

public struct CreateTargetVariables: Encodable, Sendable {
    public let input: CreateTargetInput

    public init(input: CreateTargetInput) {
        self.input = input
    }
}

public struct CreateTargetResponse: Codable, Sendable {
    public let createTarget: TargetDTO
}

// MARK: - Update Target

public struct UpdateTargetInput: Encodable, Sendable {
    public var name: String?
    public var emoji: String?
    public var strategy: String?
    public var currency: String?
    public var amountSaved: Double?
    public var amountTarget: Double?
    public var expectedStartAt: Date?
    public var expectedEndAt: Date?
    public var remindWeekly: Bool?
    public var remindMonthly: Bool?
    public var completed: Bool?
    public var archived: Bool?

    public init(
        name: String? = nil,
        emoji: String? = nil,
        strategy: String? = nil,
        currency: String? = nil,
        amountSaved: Double? = nil,
        amountTarget: Double? = nil,
        expectedStartAt: Date? = nil,
        expectedEndAt: Date? = nil,
        remindWeekly: Bool? = nil,
        remindMonthly: Bool? = nil,
        completed: Bool? = nil,
        archived: Bool? = nil
    ) {
        self.name = name
        self.emoji = emoji
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
    }

    enum CodingKeys: String, CodingKey {
        case name, emoji, strategy, currency, completed, archived
        case amountSaved = "amount_saved"
        case amountTarget = "amount_target"
        case expectedStartAt = "expected_start_at"
        case expectedEndAt = "expected_end_at"
        case remindWeekly = "remind_weekly"
        case remindMonthly = "remind_monthly"
    }
}

public struct UpdateTargetVariables: Encodable, Sendable {
    public let id: String
    public let input: UpdateTargetInput

    public init(id: String, input: UpdateTargetInput) {
        self.id = id
        self.input = input
    }
}

public struct UpdateTargetResponse: Codable, Sendable {
    public let updateTarget: TargetDTO
}
