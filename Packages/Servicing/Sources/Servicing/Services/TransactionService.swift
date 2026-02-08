import Foundation
import Dependencies
import Sharing
import ApiClient
import os.log

private let logger = Logger(subsystem: "ai.dibba.ios", category: "TransactionService")

// MARK: - Transaction Service Protocol

public protocol TransactionServicing: Sendable {
    /// Get transactions with pagination
    func getTransactions(nextToken: String?, perPage: Int) async throws -> TransactionListResult

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
    private var getTransactionsTask: Task<TransactionListResult, any Error>?
    private var loadAllTask: Task<[Transaction], any Error>?

    public init() {}

    // MARK: - Public Methods

    public var cachedTransactions: [Transaction] {
        _cachedTransactions ?? []
    }

    public func getTransactions(nextToken: String? = nil, perPage: Int = 100) async throws -> TransactionListResult {
        logger.debug("getTransactions called, nextToken: \(nextToken ?? "nil"), perPage: \(perPage)")

        // Return in-flight request if it's for the same token
        if let getTransactionsTask, nextToken == nil {
            logger.debug("Returning in-flight request")
            return try await getTransactionsTask.value
        }

        // Return cache if available and not paginating
        if let cached = _cachedTransactions, !cached.isEmpty, nextToken == nil {
            logger.debug("Returning cached transactions, count: \(cached.count)")
            return TransactionListResult(transactions: cached, nextToken: nil)
        }

        logger.info("Fetching transactions from API")

        let task = Task<TransactionListResult, any Error> {
            let data = try await client.listTransactions(nextToken: nextToken, perPage: perPage)
            let transactions = data.list.map { Transaction(from: $0) }
            logger.info("Transactions fetched, count: \(transactions.count), hasMore: \(data.nextToken != nil)")
            return TransactionListResult(transactions: transactions, nextToken: data.nextToken)
        }

        if nextToken == nil {
            getTransactionsTask = task
        }

        let result: TransactionListResult
        do {
            result = try await task.value
        } catch {
            logger.error("Failed to fetch transactions: \(error.localizedDescription)")
            if nextToken == nil { getTransactionsTask = nil }
            throw error
        }
        if nextToken == nil { getTransactionsTask = nil }

        // Update cache with new transactions (append for pagination)
        $_cachedTransactions.withLock { cached in
            if nextToken == nil {
                cached = result.transactions
                logger.debug("Cache updated with \(result.transactions.count) transactions")
            } else {
                var existing = cached ?? []
                let existingIds = Set(existing.map(\.id))
                let newTransactions = result.transactions.filter { !existingIds.contains($0.id) }
                existing.append(contentsOf: newTransactions)
                cached = existing
                logger.debug("Cache appended with \(newTransactions.count) new transactions, total: \(existing.count)")
            }
        }

        return result
    }

    public func refreshTransactions(perPage: Int = 100) async throws -> TransactionListResult {
        let cached = _cachedTransactions ?? []
        guard !cached.isEmpty else {
            logger.debug("refreshTransactions: no cache, falling back to getTransactions")
            return try await getTransactions(nextToken: nil, perPage: perPage)
        }

        let cachedIds = Set(cached.map(\.id))
        var allNewTransactions: [Transaction] = []
        var nextToken: String? = nil
        var foundOverlap = false

        logger.info("refreshTransactions: checking for new transactions, cached count: \(cached.count)")

        repeat {
            let data = try await client.listTransactions(nextToken: nextToken, perPage: perPage)
            let pageTransactions = data.list.map { Transaction(from: $0) }
            logger.debug("refreshTransactions: fetched page with \(pageTransactions.count) transactions")

            for transaction in pageTransactions {
                if cachedIds.contains(transaction.id) {
                    foundOverlap = true
                    break
                }
                allNewTransactions.append(transaction)
            }

            if foundOverlap {
                break
            }

            nextToken = data.nextToken
        } while nextToken != nil

        logger.info("refreshTransactions: found \(allNewTransactions.count) new transactions")

        if !allNewTransactions.isEmpty {
            $_cachedTransactions.withLock { cached in
                var transactions = cached ?? []
                let existingIds = Set(transactions.map(\.id))
                let dedupedNew = allNewTransactions.filter { !existingIds.contains($0.id) }
                transactions.insert(contentsOf: dedupedNew, at: 0)
                cached = transactions
                logger.debug("refreshTransactions: cache updated, total: \(transactions.count)")
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
        getTransactionsTask?.cancel()
        getTransactionsTask = nil
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
            transactionType = .purchase
        } else if dto.isTransfer == true {
            transactionType = .transfer
        } else if dto.isAtm == true {
            transactionType = .atm
        } else if dto.isCredit == true {
            transactionType = .credit
        } else if dto.isDebit == true {
            transactionType = .debit
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
