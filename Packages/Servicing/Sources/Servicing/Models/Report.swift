import Foundation

// MARK: - Report Sum

public struct ReportSum: Codable, Equatable, Sendable {
    public let total: Double
    public let diff: Double
    public let transfer: Double
    public let purchase: Double
    public let atm: Double
    public let credit: Double
    public let debit: Double

    public init(
        total: Double = 0,
        diff: Double = 0,
        transfer: Double = 0,
        purchase: Double = 0,
        atm: Double = 0,
        credit: Double = 0,
        debit: Double = 0
    ) {
        self.total = total
        self.diff = diff
        self.transfer = transfer
        self.purchase = purchase
        self.atm = atm
        self.credit = credit
        self.debit = debit
    }
}

// MARK: - Report

public struct Report: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let cards: [String: String]
    public let counts: [String: String]
    public let merchantCategories: [String: String]
    public let orgNames: [String: String]
    public let sums: [String: ReportSum]
    public let isCurrent: Bool

    public init(
        id: String,
        cards: [String: String] = [:],
        counts: [String: String] = [:],
        merchantCategories: [String: String] = [:],
        orgNames: [String: String] = [:],
        sums: [String: ReportSum] = [:],
        isCurrent: Bool = false
    ) {
        self.id = id
        self.cards = cards
        self.counts = counts
        self.merchantCategories = merchantCategories
        self.orgNames = orgNames
        self.sums = sums
        self.isCurrent = isCurrent
    }

    enum CodingKeys: String, CodingKey {
        case id, cards, counts, sums
        case merchantCategories = "merchant_categories"
        case orgNames = "org_names"
        case isCurrent
    }
}

// MARK: - Computed Properties

public extension Report {
    /// Get sum for a specific currency
    func sum(for currency: String) -> ReportSum? {
        sums[currency]
    }

    /// Total amount across all currencies (note: should only be used with single currency)
    var totalAmount: Double {
        sums.values.reduce(0) { $0 + $1.total }
    }

    /// Total purchases across all currencies
    var totalPurchases: Double {
        sums.values.reduce(0) { $0 + $1.purchase }
    }

    /// Total transfers across all currencies
    var totalTransfers: Double {
        sums.values.reduce(0) { $0 + $1.transfer }
    }
}

// MARK: - Factory

public extension Report {
    static func makeReport(
        id: String = UUID().uuidString,
        isCurrent: Bool = true,
        totalAmount: Double = 1500.0
    ) -> Report {
        Report(
            id: id,
            sums: ["USD": ReportSum(total: totalAmount, transfer: totalAmount * 0.3, purchase: totalAmount * 0.7)],
            isCurrent: isCurrent
        )
    }
}
