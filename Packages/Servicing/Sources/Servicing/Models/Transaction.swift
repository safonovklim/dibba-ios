import Foundation

// MARK: - Transaction Type

public enum TransactionType: String, Codable, Sendable, CaseIterable {
    case posPurchase = "pos_purchase"
    case atm = "atm"
    case transfer = "transfer"
    case billPayment = "bill_payment"
    case subscriptionPayment = "subscription_payment"
    case loanPayment = "loan_payment"
    case unknown = "unknown"

    public var displayName: String {
        switch self {
        case .posPurchase: "Purchase"
        case .atm: "ATM"
        case .transfer: "Transfer"
        case .billPayment: "Bill Payment"
        case .subscriptionPayment: "Subscription"
        case .loanPayment: "Loan Payment"
        case .unknown: "Unknown"
        }
    }

    public var emoji: String {
        switch self {
        case .posPurchase: "🛒"
        case .atm: "🏧"
        case .transfer: "↔️"
        case .billPayment: "🧾"
        case .subscriptionPayment: "🔄"
        case .loanPayment: "🏦"
        case .unknown: "❓"
        }
    }
}

// MARK: - Transaction Input

public struct TransactionInput: Codable, Equatable, Sendable {
    public let text: String?
    public let amount: String?
    public let merchant: String?
    public let card: String?
    public let from: String?
    public let location: String?

    public init(
        text: String? = nil,
        amount: String? = nil,
        merchant: String? = nil,
        card: String? = nil,
        from: String? = nil,
        location: String? = nil
    ) {
        self.text = text
        self.amount = amount
        self.merchant = merchant
        self.card = card
        self.from = from
        self.location = location
    }
}

// MARK: - Transaction Metadata

public struct TransactionMetadata: Codable, Equatable, Sendable {
    public let type: String
    public let userAgent: String?
    public let ipAddress: String?

    public init(
        type: String = "manual",
        userAgent: String? = nil,
        ipAddress: String? = nil
    ) {
        self.type = type
        self.userAgent = userAgent
        self.ipAddress = ipAddress
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userAgent = "user_agent"
        case ipAddress = "ip_address"
    }
}

// MARK: - Transaction

public struct Transaction: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let accountNumber: String
    public let cardNumber: String
    public let name: String
    public let merchantCategory: String
    public let amount: Double
    public let currency: String
    public let success: Bool
    public let isCredit: Bool
    public let isDebit: Bool
    public let isAtm: Bool
    public let isPurchase: Bool
    public let isTransfer: Bool
    public let fullDate: String
    public let orgType: String
    public let orgName: String
    public let transactionType: TransactionType
    public let errorMessage: String?
    public let input: TransactionInput?
    public let metadata: TransactionMetadata?
    public let createdAt: Date

    public init(
        id: String,
        accountNumber: String = "",
        cardNumber: String = "",
        name: String,
        merchantCategory: String = "",
        amount: Double,
        currency: String,
        success: Bool = true,
        isCredit: Bool = false,
        isDebit: Bool = false,
        isAtm: Bool = false,
        isPurchase: Bool = false,
        isTransfer: Bool = false,
        fullDate: String = "",
        orgType: String = "",
        orgName: String = "",
        transactionType: TransactionType = .unknown,
        errorMessage: String? = nil,
        input: TransactionInput? = nil,
        metadata: TransactionMetadata? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.accountNumber = accountNumber
        self.cardNumber = cardNumber
        self.name = name
        self.merchantCategory = merchantCategory
        self.amount = amount
        self.currency = currency
        self.success = success
        self.isCredit = isCredit
        self.isDebit = isDebit
        self.isAtm = isAtm
        self.isPurchase = isPurchase
        self.isTransfer = isTransfer
        self.fullDate = fullDate
        self.orgType = orgType
        self.orgName = orgName
        self.transactionType = transactionType
        self.errorMessage = errorMessage
        self.input = input
        self.metadata = metadata
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case accountNumber = "account_number"
        case cardNumber = "card_number"
        case name
        case merchantCategory = "merchant_category"
        case amount, currency, success
        case isCredit = "is_credit"
        case isDebit = "is_debit"
        case isAtm = "is_atm"
        case isPurchase = "is_purchase"
        case isTransfer = "is_transfer"
        case fullDate = "full_date"
        case orgType = "org_type"
        case orgName = "org_name"
        case transactionType = "transaction_type"
        case errorMessage = "error_message"
        case input, metadata
        case createdAt = "created_at"
    }
}

// MARK: - Computed Properties

public extension Transaction {
    var computedType: TransactionType {
        if isPurchase { return .posPurchase }
        if isTransfer { return .transfer }
        if isAtm { return .atm }
        return transactionType
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    var isIncome: Bool {
        isCredit || amount > 0
    }

    var isExpense: Bool {
        isDebit || amount < 0
    }
}

// MARK: - Factory

public extension Transaction {
    static func makeTransaction(
        id: String = UUID().uuidString,
        name: String = "Test Transaction",
        amount: Double = -50.0,
        currency: String = "USD",
        type: TransactionType = .posPurchase
    ) -> Transaction {
        Transaction(
            id: id,
            name: name,
            amount: amount,
            currency: currency,
            isAtm: type == .atm,
            isPurchase: type == .posPurchase,
            isTransfer: type == .transfer,
            transactionType: type
        )
    }
}
