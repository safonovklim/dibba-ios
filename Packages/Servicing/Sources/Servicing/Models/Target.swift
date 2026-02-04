import Foundation

// MARK: - Target Strategy

public enum TargetStrategy: String, Codable, Sendable, CaseIterable {
    case fixedAmountWeekly = "FIXED_AMOUNT_WEEKLY"
    case fixedAmountMonthly = "FIXED_AMOUNT_MONTHLY"
    case fixedIncomePercent = "FIXED_INCOME_PERCENT"
    case open = "OPEN"

    public var displayName: String {
        switch self {
        case .fixedAmountWeekly: "Fixed Weekly"
        case .fixedAmountMonthly: "Fixed Monthly"
        case .fixedIncomePercent: "Income Percentage"
        case .open: "Open (Manual)"
        }
    }

    public var description: String {
        switch self {
        case .fixedAmountWeekly:
            "Save a fixed amount every week"
        case .fixedAmountMonthly:
            "Save a fixed amount every month"
        case .fixedIncomePercent:
            "Save a percentage of your income"
        case .open:
            "Add to savings manually whenever you want"
        }
    }
}

// MARK: - Target (Savings Goal)

public struct Target: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let userId: String
    public let emoji: String
    public let name: String
    public let strategy: TargetStrategy
    public let currency: String
    public let amountSaved: Double
    public let amountTarget: Double
    public let expectedStartAt: Date
    public let expectedEndAt: Date
    public let remindWeekly: Bool
    public let remindMonthly: Bool
    public let completed: Bool
    public let archived: Bool
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String = UUID().uuidString,
        userId: String = "",
        emoji: String = "🎯",
        name: String,
        strategy: TargetStrategy = .open,
        currency: String = "USD",
        amountSaved: Double = 0,
        amountTarget: Double,
        expectedStartAt: Date = Date(),
        expectedEndAt: Date,
        remindWeekly: Bool = false,
        remindMonthly: Bool = true,
        completed: Bool = false,
        archived: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
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

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case emoji, name, strategy, currency
        case amountSaved = "amount_saved"
        case amountTarget = "amount_target"
        case expectedStartAt = "expected_start_at"
        case expectedEndAt = "expected_end_at"
        case remindWeekly = "remind_weekly"
        case remindMonthly = "remind_monthly"
        case completed, archived
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Computed Properties

public extension Target {
    /// Progress as a value between 0 and 1
    var progress: Double {
        guard amountTarget > 0 else { return 0 }
        return min(amountSaved / amountTarget, 1.0)
    }

    /// Progress as a percentage (0-100)
    var progressPercent: Int {
        Int(progress * 100)
    }

    /// Amount remaining to reach the goal
    var amountRemaining: Double {
        max(amountTarget - amountSaved, 0)
    }

    /// Days remaining until target date
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expectedEndAt)
        return max(components.day ?? 0, 0)
    }

    /// Whether the target is active (not completed or archived)
    var isActive: Bool {
        !completed && !archived
    }

    /// Whether the target is overdue
    var isOverdue: Bool {
        !completed && expectedEndAt < Date()
    }

    /// Formatted amount saved
    var formattedAmountSaved: String {
        formatCurrency(amountSaved)
    }

    /// Formatted target amount
    var formattedAmountTarget: String {
        formatCurrency(amountTarget)
    }

    /// Formatted remaining amount
    var formattedAmountRemaining: String {
        formatCurrency(amountRemaining)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

// MARK: - Factory

public extension Target {
    static func makeTarget(
        id: String = UUID().uuidString,
        name: String = "Vacation Fund",
        emoji: String = "🏖️",
        amountSaved: Double = 500,
        amountTarget: Double = 2000,
        currency: String = "USD"
    ) -> Target {
        Target(
            id: id,
            emoji: emoji,
            name: name,
            currency: currency,
            amountSaved: amountSaved,
            amountTarget: amountTarget,
            expectedEndAt: Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
        )
    }
}

// MARK: - Target Suggestion

public struct TargetSuggestion: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let emoji: String
    public let title: String
    public let description: String
    public let suggestedAmount: Double

    public init(
        id: String,
        emoji: String,
        title: String,
        description: String,
        suggestedAmount: Double
    ) {
        self.id = id
        self.emoji = emoji
        self.title = title
        self.description = description
        self.suggestedAmount = suggestedAmount
    }
}
