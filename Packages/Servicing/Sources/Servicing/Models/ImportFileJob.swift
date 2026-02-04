import Foundation

// MARK: - Import Job Status

public enum ImportJobStatus: String, Codable, Sendable, CaseIterable {
    case pending = "PENDING"
    case processing = "PROCESSING"
    case completed = "COMPLETED"
    case failed = "FAILED"

    public var displayName: String {
        switch self {
        case .pending: "Pending"
        case .processing: "Processing"
        case .completed: "Completed"
        case .failed: "Failed"
        }
    }

    public var emoji: String {
        switch self {
        case .pending: "⏳"
        case .processing: "🔄"
        case .completed: "✅"
        case .failed: "❌"
        }
    }

    public var isTerminal: Bool {
        self == .completed || self == .failed
    }
}

// MARK: - Import File Job

public struct ImportFileJob: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let fileName: String
    public let fileType: String
    public let pagesCount: Int
    public let pagesFailedTotal: Int
    public let pagesProcessedTotal: Int
    public let transactionsTotal: Int
    public let purchasesTotal: Int
    public let transfersTotal: Int
    public let atmTotal: Int
    public let creditTotal: Int
    public let debitTotal: Int
    public let s3FilesUploadUrls: [String]
    public let status: String
    public let errors: [String]?
    public let createdAt: Date?
    public let startedAt: Date?
    public let finishedAt: Date?

    public init(
        id: String,
        fileName: String,
        fileType: String = "pdf",
        pagesCount: Int = 0,
        pagesFailedTotal: Int = 0,
        pagesProcessedTotal: Int = 0,
        transactionsTotal: Int = 0,
        purchasesTotal: Int = 0,
        transfersTotal: Int = 0,
        atmTotal: Int = 0,
        creditTotal: Int = 0,
        debitTotal: Int = 0,
        s3FilesUploadUrls: [String] = [],
        status: String = "PENDING",
        errors: [String]? = nil,
        createdAt: Date? = nil,
        startedAt: Date? = nil,
        finishedAt: Date? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.fileType = fileType
        self.pagesCount = pagesCount
        self.pagesFailedTotal = pagesFailedTotal
        self.pagesProcessedTotal = pagesProcessedTotal
        self.transactionsTotal = transactionsTotal
        self.purchasesTotal = purchasesTotal
        self.transfersTotal = transfersTotal
        self.atmTotal = atmTotal
        self.creditTotal = creditTotal
        self.debitTotal = debitTotal
        self.s3FilesUploadUrls = s3FilesUploadUrls
        self.status = status
        self.errors = errors
        self.createdAt = createdAt
        self.startedAt = startedAt
        self.finishedAt = finishedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, status, errors
        case fileName = "file_name"
        case fileType = "file_type"
        case pagesCount = "pages_count"
        case pagesFailedTotal = "pages_failed_total"
        case pagesProcessedTotal = "pages_processed_total"
        case transactionsTotal = "transactions_total"
        case purchasesTotal = "purchases_total"
        case transfersTotal = "transfers_total"
        case atmTotal = "atm_total"
        case creditTotal = "credit_total"
        case debitTotal = "debit_total"
        case s3FilesUploadUrls = "s3_files_upload_urls"
        case createdAt = "created_at"
        case startedAt = "started_at"
        case finishedAt = "finished_at"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fileName = try container.decode(String.self, forKey: .fileName)
        fileType = try container.decode(String.self, forKey: .fileType)
        pagesCount = try container.decode(Int.self, forKey: .pagesCount)
        pagesFailedTotal = try container.decode(Int.self, forKey: .pagesFailedTotal)
        pagesProcessedTotal = try container.decode(Int.self, forKey: .pagesProcessedTotal)
        transactionsTotal = try container.decode(Int.self, forKey: .transactionsTotal)
        purchasesTotal = try container.decode(Int.self, forKey: .purchasesTotal)
        transfersTotal = try container.decode(Int.self, forKey: .transfersTotal)
        atmTotal = try container.decode(Int.self, forKey: .atmTotal)
        creditTotal = try container.decode(Int.self, forKey: .creditTotal)
        debitTotal = try container.decode(Int.self, forKey: .debitTotal)
        s3FilesUploadUrls = try container.decode([String].self, forKey: .s3FilesUploadUrls)
        status = try container.decode(String.self, forKey: .status)
        errors = try container.decodeIfPresent([String].self, forKey: .errors)

        // Handle timestamp decoding
        if let timestamp = try container.decodeIfPresent(Int.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: TimeInterval(timestamp))
        } else {
            createdAt = nil
        }

        if let timestamp = try container.decodeIfPresent(Int.self, forKey: .startedAt) {
            startedAt = Date(timeIntervalSince1970: TimeInterval(timestamp))
        } else {
            startedAt = nil
        }

        if let timestamp = try container.decodeIfPresent(Int.self, forKey: .finishedAt) {
            finishedAt = Date(timeIntervalSince1970: TimeInterval(timestamp))
        } else {
            finishedAt = nil
        }
    }
}

// MARK: - Computed Properties

public extension ImportFileJob {
    var jobStatus: ImportJobStatus {
        ImportJobStatus(rawValue: status) ?? .pending
    }

    var isCompleted: Bool {
        jobStatus == .completed
    }

    var isFailed: Bool {
        jobStatus == .failed
    }

    var isProcessing: Bool {
        jobStatus == .processing
    }

    var progress: Double {
        guard pagesCount > 0 else { return 0 }
        return Double(pagesProcessedTotal) / Double(pagesCount)
    }

    var progressPercent: Int {
        Int(progress * 100)
    }

    var hasErrors: Bool {
        guard let errors else { return false }
        return !errors.isEmpty
    }

    var processingDuration: TimeInterval? {
        guard let startedAt, let finishedAt else { return nil }
        return finishedAt.timeIntervalSince(startedAt)
    }

    var formattedDuration: String? {
        guard let duration = processingDuration else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration)
    }
}

// MARK: - Factory

public extension ImportFileJob {
    static func makeJob(
        id: String = UUID().uuidString,
        fileName: String = "statement.pdf",
        status: String = "PENDING",
        pagesCount: Int = 10,
        pagesProcessed: Int = 0
    ) -> ImportFileJob {
        ImportFileJob(
            id: id,
            fileName: fileName,
            pagesCount: pagesCount,
            pagesProcessedTotal: pagesProcessed,
            status: status,
            createdAt: Date()
        )
    }
}
