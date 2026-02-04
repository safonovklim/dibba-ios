import Foundation

// MARK: - Report Queries

public enum ReportQueries {
    public static let listReports = """
        query listReports($ids: [String]!) {
            listReports(ids: $ids) {
                id
                cards_json
                counts_json
                merchant_categories_json
                org_names_json
                sums_json
            }
        }
        """
}
