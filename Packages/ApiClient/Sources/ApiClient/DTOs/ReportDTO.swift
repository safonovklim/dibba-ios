import Foundation

// MARK: - Report DTO

public struct ReportDTO: Codable, Sendable {
    public let id: String
    public let cardsJson: String?
    public let countsJson: String?
    public let merchantCategoriesJson: String?
    public let orgNamesJson: String?
    public let sumsJson: String?

    enum CodingKeys: String, CodingKey {
        case id
        case cardsJson = "cards_json"
        case countsJson = "counts_json"
        case merchantCategoriesJson = "merchant_categories_json"
        case orgNamesJson = "org_names_json"
        case sumsJson = "sums_json"
    }
}

// MARK: - Report Sum DTO

public struct ReportSumDTO: Codable, Sendable {
    public let total: Double
    public let diff: Double
    public let transfer: Double
    public let purchase: Double
    public let atm: Double
    public let credit: Double
    public let debit: Double
}

// MARK: - List Reports Response

public struct ListReportsResponse: Codable, Sendable {
    public let listReports: [ReportDTO]
}

public struct ListReportsVariables: Encodable, Sendable {
    public let ids: [String]

    public init(ids: [String]) {
        self.ids = ids
    }
}
