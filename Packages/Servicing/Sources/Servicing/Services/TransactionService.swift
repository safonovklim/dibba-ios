import Foundation
import Dependencies
import Sharing
import ApiClient
import os.log

private let logger = Logger(subsystem: "ai.dibba.ios", category: "TransactionService")

// MARK: - Transaction Service Protocol

public protocol TransactionServicing: Sendable {
    /// Fetch a single page of transactions from the API and append to cache
    func fetchPage(nextToken: String?, perPage: Int) async throws -> TransactionListResult

    /// Load all transactions up to a date
    func loadAllTransactions(untilDate: Date?) async throws -> [Transaction]

    /// Create a new transaction
    func createTransaction(_ input: CreateTransactionInput) async throws -> Transaction

    /// Update an existing transaction
    func updateTransaction(id: String, input: UpdateTransactionInput) async throws -> Transaction

    /// Delete a transaction
    func deleteTransaction(id: String) async throws -> Bool

    /// Get cached transactions
    var cachedTransactions: [Transaction] { get async }

    /// Refresh transactions incrementally (fetch new ones until overlap with cache)
    func refreshTransactions(perPage: Int) async throws -> TransactionListResult

    /// Clear cached data
    func clearCache() async
}

// MARK: - Transaction List Result

public struct TransactionListResult: Sendable {
    public let transactions: [Transaction]
    public let nextToken: String?

    public init(transactions: [Transaction], nextToken: String?) {
        self.transactions = transactions
        self.nextToken = nextToken
    }
}

// MARK: - Transaction Service Implementation

public actor TransactionService: TransactionServicing {
    @Dependency(\.apiClient) private var client

    // File storage cache for list data
    @Shared(.fileStorage(
        .cachesDirectory.appending(components: "cachedTransactions.json")
    )) private var _cachedTransactions: [Transaction]?

    // Task deduplication
    private var loadAllTask: Task<[Transaction], any Error>?

    public init() {}

    // MARK: - Public Methods

    public var cachedTransactions: [Transaction] {
        _cachedTransactions ?? []
    }

    public func fetchPage(nextToken: String? = nil, perPage: Int = 100) async throws -> TransactionListResult {
        logger.debug("fetchPage called, nextToken: \(nextToken ?? "nil"), perPage: \(perPage)")

        let data = try await client.listTransactions(nextToken: nextToken, perPage: perPage)
        let page = data.list.map { Transaction(from: $0) }

        $_cachedTransactions.withLock { cached in
            var existing = cached ?? []
            let existingIds = Set(existing.map(\.id))
            let newItems = page.filter { !existingIds.contains($0.id) }
            existing.append(contentsOf: newItems)
            cached = existing
            logger.debug("fetchPage: appended \(newItems.count) to cache, total: \(existing.count)")
        }

        return TransactionListResult(transactions: page, nextToken: data.nextToken)
    }

    public func refreshTransactions(perPage: Int = 100) async throws -> TransactionListResult {
        let cached = _cachedTransactions ?? []
        guard !cached.isEmpty else {
            logger.debug("refreshTransactions: no cache, loading all pages")
            var token: String? = nil
            repeat {
                let page = try await fetchPage(nextToken: token, perPage: perPage)
                token = page.nextToken
            } while token != nil
            return TransactionListResult(transactions: _cachedTransactions ?? [], nextToken: nil)
        }

        let cachedIds = Set(cached.map(\.id))
        var newTransactions: [Transaction] = []
        var pageToken: String? = nil
        var foundOverlap = false

        logger.info("refreshTransactions: checking for new transactions, cached count: \(cached.count)")

        repeat {
            let data = try await client.listTransactions(nextToken: pageToken, perPage: perPage)
            let page = data.list.map { Transaction(from: $0) }
            logger.debug("refreshTransactions: fetched page with \(page.count) transactions")

            for transaction in page {
                if cachedIds.contains(transaction.id) {
                    foundOverlap = true
                    break
                }
                newTransactions.append(transaction)
            }

            if foundOverlap { break }
            pageToken = data.nextToken
        } while pageToken != nil

        logger.info("refreshTransactions: found \(newTransactions.count) new transactions")

        if !newTransactions.isEmpty {
            $_cachedTransactions.withLock { cached in
                var existing = cached ?? []
                let existingIds = Set(existing.map(\.id))
                let deduped = newTransactions.filter { !existingIds.contains($0.id) }
                existing.insert(contentsOf: deduped, at: 0)
                cached = existing
                logger.debug("refreshTransactions: prepended \(deduped.count), total: \(existing.count)")
            }
        }

        let updatedCache = _cachedTransactions ?? []
        return TransactionListResult(transactions: updatedCache, nextToken: nil)
    }

    public func loadAllTransactions(untilDate: Date? = nil) async throws -> [Transaction] {
        // Return in-flight request if exists
        if let loadAllTask {
            return try await loadAllTask.value
        }

        let task = Task<[Transaction], any Error> {
            var allTransactions: [Transaction] = []
            var nextToken: String? = nil
            let targetTimestamp = (untilDate ?? Calendar.current.date(byAdding: .year, value: -1, to: Date()))!.timeIntervalSince1970

            repeat {
                let result = try await client.listTransactions(nextToken: nextToken, perPage: 100)
                let transactions = result.list.map { Transaction(from: $0) }
                allTransactions.append(contentsOf: transactions)

                // Check if we've reached the target date
                if let lastTransaction = transactions.last,
                   lastTransaction.createdAt.timeIntervalSince1970 < targetTimestamp {
                    break
                }

                nextToken = result.nextToken
            } while nextToken != nil

            return allTransactions
        }

        loadAllTask = task
        defer { loadAllTask = nil }

        let transactions = try await task.value
        $_cachedTransactions.withLock { $0 = transactions }
        return transactions
    }

    public func createTransaction(_ input: CreateTransactionInput) async throws -> Transaction {
        let dto = try await client.createTransaction(input: input)
        let transaction = Transaction(from: dto)

        // Add to cache
        $_cachedTransactions.withLock { cached in
            var transactions = cached ?? []
            transactions.insert(transaction, at: 0)
            cached = transactions
        }

        return transaction
    }

    public func updateTransaction(id: String, input: UpdateTransactionInput) async throws -> Transaction {
        let dto = try await client.updateTransaction(id: id, input: input)
        let transaction = Transaction(from: dto)

        // Update cache
        $_cachedTransactions.withLock { cached in
            guard var transactions = cached else { return }
            if let index = transactions.firstIndex(where: { $0.id == id }) {
                transactions[index] = transaction
                cached = transactions
            }
        }

        return transaction
    }

    public func deleteTransaction(id: String) async throws -> Bool {
        let success = try await client.deleteTransaction(id: id)

        if success {
            // Remove from cache
            $_cachedTransactions.withLock { cached in
                cached = cached?.filter { $0.id != id }
            }
        }

        return success
    }

    public func clearCache() {
        $_cachedTransactions.withLock { $0 = nil }
        loadAllTask?.cancel()
        loadAllTask = nil
    }
}

// MARK: - Transaction Conversion

extension Transaction {
    init(from dto: TransactionDTO) {
        let transactionType: TransactionType
        if let typeString = dto.transactionType {
            transactionType = TransactionType(rawValue: typeString) ?? .unknown
        } else if dto.isPurchase == true {
            transactionType = .posPurchase
        } else if dto.isTransfer == true {
            transactionType = .transfer
        } else if dto.isAtm == true {
            transactionType = .atm
        } else {
            transactionType = .unknown
        }

        self.init(
            id: dto.id,
            accountNumber: dto.accountNumber ?? "",
            cardNumber: dto.cardNumber ?? "",
            name: dto.name,
            merchantCategory: dto.merchantCategory ?? "",
            amount: dto.amount,
            currency: dto.currency,
            success: dto.success ?? true,
            isCredit: dto.isCredit ?? false,
            isDebit: dto.isDebit ?? false,
            isAtm: dto.isAtm ?? false,
            isPurchase: dto.isPurchase ?? false,
            isTransfer: dto.isTransfer ?? false,
            fullDate: dto.fullDate ?? "",
            orgType: dto.orgType ?? "",
            orgName: dto.orgName ?? "",
            transactionType: transactionType,
            errorMessage: dto.errorMessage,
            input: dto.input.map { TransactionInput(from: $0) },
            metadata: dto.metadata.map { TransactionMetadata(from: $0) },
            createdAt: dto.createdAt ?? Date()
        )
    }
}

extension TransactionInput {
    init(from dto: TransactionInputDTO) {
        self.init(
            text: dto.text,
            from: dto.from,
            location: dto.location
        )
    }
}

extension TransactionMetadata {
    init(from dto: TransactionMetadataDTO) {
        self.init(
            type: dto.type ?? "unknown",
            userAgent: dto.identity?.userAgent,
            ipAddress: dto.identity?.ipAddress
        )
    }
}

// MARK: - Dependency Registration

extension TransactionService: DependencyKey {
    public static let liveValue: any TransactionServicing = TransactionService()
    public static let testValue: any TransactionServicing = TransactionService()
}

public extension DependencyValues {
    var transactionService: any TransactionServicing {
        get { self[TransactionService.self] }
        set { self[TransactionService.self] = newValue }
    }
}
