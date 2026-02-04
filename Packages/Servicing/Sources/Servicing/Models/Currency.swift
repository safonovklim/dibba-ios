import Foundation

/// Currency representation with emoji and region info
public struct Currency: Codable, Equatable, Sendable, Identifiable, Hashable {
    public let id: String
    public let label: String
    public let emoji: String
    public let continent: String
    public let timezones: [String]

    public init(
        id: String,
        label: String,
        emoji: String,
        continent: String,
        timezones: [String]
    ) {
        self.id = id
        self.label = label
        self.emoji = emoji
        self.continent = continent
        self.timezones = timezones
    }
}

// MARK: - Common Currencies

public extension Currency {
    static let usd = Currency(
        id: "USD",
        label: "US Dollar",
        emoji: "🇺🇸",
        continent: "North America",
        timezones: ["America/New_York", "America/Los_Angeles"]
    )

    static let eur = Currency(
        id: "EUR",
        label: "Euro",
        emoji: "🇪🇺",
        continent: "Europe",
        timezones: ["Europe/Paris", "Europe/Berlin"]
    )

    static let gbp = Currency(
        id: "GBP",
        label: "British Pound",
        emoji: "🇬🇧",
        continent: "Europe",
        timezones: ["Europe/London"]
    )
}
