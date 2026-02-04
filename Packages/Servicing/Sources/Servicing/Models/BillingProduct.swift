import Foundation

// MARK: - Product Type

public enum ProductType: String, Codable, Sendable, CaseIterable {
    case subscription = "SUBSCRIPTION"
    case oneTime = "ONE_TIME"
    case credits = "CREDITS"

    public var displayName: String {
        switch self {
        case .subscription: "Subscription"
        case .oneTime: "One-Time Purchase"
        case .credits: "Credits"
        }
    }
}

// MARK: - Product Experience

public enum ProductExperience: String, Codable, Sendable, CaseIterable {
    case basic = "BASIC"
    case premium = "PREMIUM"
    case pro = "PRO"

    public var displayName: String {
        switch self {
        case .basic: "Basic"
        case .premium: "Premium"
        case .pro: "Pro"
        }
    }
}

// MARK: - Billing Product

public struct BillingProduct: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let shortTitle: String
    public let description: String
    public let type: String
    public let featuresIncluded: [String]
    public let featuresExcluded: [String]
    public let creditsMultiplier: Double
    public let price: Double
    public let currency: String
    public let isFree: Bool
    public let canOrder: Bool
    public let hasTrial: Bool
    public let trialPeriodInDays: Int
    public let current: Bool
    public let priority: Int
    public let experience: String

    public init(
        id: String,
        title: String,
        shortTitle: String = "",
        description: String = "",
        type: String = "SUBSCRIPTION",
        featuresIncluded: [String] = [],
        featuresExcluded: [String] = [],
        creditsMultiplier: Double = 1.0,
        price: Double,
        currency: String = "USD",
        isFree: Bool = false,
        canOrder: Bool = true,
        hasTrial: Bool = false,
        trialPeriodInDays: Int = 0,
        current: Bool = false,
        priority: Int = 0,
        experience: String = "BASIC"
    ) {
        self.id = id
        self.title = title
        self.shortTitle = shortTitle
        self.description = description
        self.type = type
        self.featuresIncluded = featuresIncluded
        self.featuresExcluded = featuresExcluded
        self.creditsMultiplier = creditsMultiplier
        self.price = price
        self.currency = currency
        self.isFree = isFree
        self.canOrder = canOrder
        self.hasTrial = hasTrial
        self.trialPeriodInDays = trialPeriodInDays
        self.current = current
        self.priority = priority
        self.experience = experience
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, type, price, currency, current, priority, experience
        case shortTitle = "short_title"
        case featuresIncluded = "features_included"
        case featuresExcluded = "features_excluded"
        case creditsMultiplier = "credits_multiplier"
        case isFree = "is_free"
        case canOrder = "can_order"
        case hasTrial = "has_trial"
        case trialPeriodInDays = "trial_period_in_days"
    }
}

// MARK: - Computed Properties

public extension BillingProduct {
    var productType: ProductType? {
        ProductType(rawValue: type)
    }

    var productExperience: ProductExperience? {
        ProductExperience(rawValue: experience)
    }

    var formattedPrice: String {
        if isFree { return "Free" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }

    var trialDescription: String? {
        guard hasTrial, trialPeriodInDays > 0 else { return nil }
        return "\(trialPeriodInDays)-day free trial"
    }

    var isPremium: Bool {
        experience == "PREMIUM" || experience == "PRO"
    }
}

// MARK: - Factory

public extension BillingProduct {
    static func makeProduct(
        id: String = UUID().uuidString,
        title: String = "Premium Plan",
        price: Double = 9.99,
        isFree: Bool = false
    ) -> BillingProduct {
        BillingProduct(
            id: id,
            title: title,
            shortTitle: "Premium",
            description: "Unlock all features",
            featuresIncluded: ["Unlimited transactions", "Advanced analytics", "Priority support"],
            price: price,
            isFree: isFree,
            hasTrial: true,
            trialPeriodInDays: 7,
            experience: isFree ? "BASIC" : "PREMIUM"
        )
    }

    static let freePlan = BillingProduct(
        id: "free",
        title: "Free Plan",
        shortTitle: "Free",
        description: "Basic features",
        featuresIncluded: ["Up to 100 transactions", "Basic reports"],
        featuresExcluded: ["Advanced analytics", "Priority support", "API access"],
        price: 0,
        isFree: true,
        experience: "BASIC"
    )
}
