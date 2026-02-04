import Foundation
import Dependencies
import Sharing
import ApiClient

// MARK: - Report Service Protocol

public protocol ReportServicing: Sendable {
    /// Get reports by IDs
    func getReports(ids: [String], isCurrent: Bool) async throws -> [Report]

    /// Get current month report
    func getCurrentReport() async throws -> Report?

    /// Get cached reports
    var cachedReports: [Report] { get async }

    /// Clear cached data
    func clearCache() async
}

// MARK: - Report Service Implementation

public actor ReportService: ReportServicing {
    @Dependency(\.apiClient) private var client

    // File storage cache for reports
    @Shared(.fileStorage(
        .cachesDirectory.appending(components: "cachedReports.json")
    )) private var _cachedReports: [Report]?

    // Task deduplication
    private var getReportsTask: [String: Task<[Report], any Error>] = [:]

    public init() {}

    // MARK: - Public Methods

    public var cachedReports: [Report] {
        _cachedReports ?? []
    }

    public func getReports(ids: [String], isCurrent: Bool = false) async throws -> [Report] {
        let cacheKey = ids.joined(separator: ",")

        // Return in-flight request if exists
        if let existingTask = getReportsTask[cacheKey] {
            return try await existingTask.value
        }

        // Check cache for these IDs
        let cachedForIds = (_cachedReports ?? []).filter { ids.contains($0.id) }
        if cachedForIds.count == ids.count {
            return cachedForIds
        }

        let task = Task<[Report], any Error> {
            let dtos = try await client.listReports(ids: ids)
            return dtos.map { Report(from: $0, isCurrent: isCurrent) }
        }

        getReportsTask[cacheKey] = task
        defer { getReportsTask[cacheKey] = nil }

        let reports = try await task.value

        // Update cache
        $_cachedReports.withLock { cached in
            var existing = cached ?? []

            for report in reports {
                if let index = existing.firstIndex(where: { $0.id == report.id }) {
                    existing[index] = report
                } else {
                    existing.append(report)
                }
            }

            cached = existing
        }

        return reports
    }

    public func getCurrentReport() async throws -> Report? {
        // Generate current month report ID (format: YYYY-MM)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let currentMonthId = formatter.string(from: Date())

        let reports = try await getReports(ids: [currentMonthId], isCurrent: true)
        return reports.first
    }

    public func clearCache() {
        $_cachedReports.withLock { $0 = nil }
        for task in getReportsTask.values {
            task.cancel()
        }
        getReportsTask.removeAll()
    }
}

// MARK: - Report Conversion

extension Report {
    init(from dto: ReportDTO, isCurrent: Bool) {
        // Parse JSON strings
        let cards = Self.parseJsonDict(dto.cardsJson)
        let counts = Self.parseJsonDict(dto.countsJson)
        let merchantCategories = Self.parseJsonDict(dto.merchantCategoriesJson)
        let orgNames = Self.parseJsonDict(dto.orgNamesJson)
        let sums = Self.parseJsonSums(dto.sumsJson)

        self.init(
            id: dto.id,
            cards: cards,
            counts: counts,
            merchantCategories: merchantCategories,
            orgNames: orgNames,
            sums: sums,
            isCurrent: isCurrent
        )
    }

    private static func parseJsonDict(_ json: String?) -> [String: String] {
        guard let json, let data = json.data(using: .utf8) else { return [:] }
        return (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
    }

    private static func parseJsonSums(_ json: String?) -> [String: ReportSum] {
        guard let json, let data = json.data(using: .utf8) else { return [:] }

        struct RawSum: Codable {
            let total: Double
            let diff: Double
            let transfer: Double
            let purchase: Double
            let atm: Double
            let credit: Double
            let debit: Double
        }

        guard let rawSums = try? JSONDecoder().decode([String: RawSum].self, from: data) else {
            return [:]
        }

        return rawSums.mapValues { raw in
            ReportSum(
                total: raw.total,
                diff: raw.diff,
                transfer: raw.transfer,
                purchase: raw.purchase,
                atm: raw.atm,
                credit: raw.credit,
                debit: raw.debit
            )
        }
    }
}

// MARK: - Dependency Registration

extension ReportService: DependencyKey {
    public static let liveValue: any ReportServicing = ReportService()
    public static let testValue: any ReportServicing = ReportService()
}

public extension DependencyValues {
    var reportService: any ReportServicing {
        get { self[ReportService.self] }
        set { self[ReportService.self] = newValue }
    }
}
