import Dependencies
import os.log
import Servicing
import SwiftUI

private let logger = Logger(subsystem: "ai.dibba.ios", category: "FeedView")

public struct FeedView: View {
    public init() {}

    @Dependency(\.transactionService) private var transactionService

    @State private var transactions: [Servicing.Transaction] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var nextToken: String?

    public var body: some View {
        let _ = logger.debug("body rendered - transactions: \(transactions.count), isLoading: \(isLoading), hasError: \(errorMessage != nil), hasMore: \(nextToken != nil)")
        NavigationStack {
            Group {
                if isLoading && transactions.isEmpty {
                    let _ = logger.debug("Rendering loading state")
                    loadingView
                } else if let error = errorMessage, transactions.isEmpty {
                    let _ = logger.debug("Rendering error state: \(error)")
                    errorView(error)
                } else if transactions.isEmpty {
                    let _ = logger.debug("Rendering empty state")
                    emptyView
                } else {
                    let _ = logger.debug("Rendering transaction list with \(transactions.count) items")
                    transactionList
                }
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isLoading && !transactions.isEmpty {
                        ProgressView()
                    }
                }
            }
            .task {
                await loadTransactions()
            }
            .refreshable {
                await loadTransactions(force: true)
            }
        }
    }

    // MARK: - Views

    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading transactions...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Error", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry") {
                Task { await loadTransactions() }
            }
        }
    }

    @ViewBuilder
    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Transactions", systemImage: "tray")
        } description: {
            Text("Your transactions will appear here")
        }
    }

    @ViewBuilder
    private var transactionList: some View {
        List {
            ForEach(transactions) { transaction in
                TransactionRow(transaction: transaction)
            }

            if nextToken != nil {
                HStack {
                    Spacer()
                    ProgressView()
                        .task {
                            await loadMore()
                        }
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Data Loading

    private func loadTransactions(force: Bool = false) async {
        logger.info("loadTransactions started, force: \(force)")
        guard !isLoading else {
            logger.debug("loadTransactions skipped - already loading")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await transactionService.getTransactions(nextToken: nil, perPage: 50)
            transactions = result.transactions
            nextToken = result.nextToken
            logger.info("Transactions loaded successfully, count: \(result.transactions.count), hasMore: \(result.nextToken != nil)")
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Failed to load transactions: \(error.localizedDescription)")
        }

        isLoading = false
        logger.debug("loadTransactions completed, isLoading: false")
    }

    private func loadMore() async {
        logger.debug("loadMore called, nextToken: \(nextToken ?? "nil")")
        guard let token = nextToken, !isLoading else {
            logger.debug("loadMore skipped - no token or already loading")
            return
        }

        logger.info("Loading more transactions...")
        isLoading = true

        do {
            let result = try await transactionService.getTransactions(nextToken: token, perPage: 50)
            transactions.append(contentsOf: result.transactions)
            nextToken = result.nextToken
            logger.info("More transactions loaded, added: \(result.transactions.count), total: \(transactions.count), hasMore: \(result.nextToken != nil)")
        } catch {
            logger.error("Failed to load more transactions: \(error.localizedDescription)")
            // Silently fail for pagination errors
        }

        isLoading = false
    }
}

// MARK: - Transaction Row

private struct TransactionRow: View {
    let transaction: Servicing.Transaction

    var body: some View {
        HStack(spacing: 12) {
            // Type indicator
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 44, height: 44)

                Text(transaction.transactionType.emoji)
                    .font(.title3)
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if !transaction.orgName.isEmpty {
                        Text(transaction.orgName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    if !transaction.merchantCategory.isEmpty {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text(transaction.merchantCategory)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.formattedAmount)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(amountColor)

                Text(formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    private var backgroundColor: Color {
        transaction.isIncome ? Color.green.opacity(0.15) : Color.red.opacity(0.1)
    }

    private var amountColor: Color {
        transaction.isIncome ? .green : .primary
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: transaction.createdAt)
    }
}
