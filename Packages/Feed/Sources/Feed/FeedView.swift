import Dependencies
import os.log
import Servicing
import SwiftUI

private let logger = Logger(subsystem: "ai.dibba.ios", category: "FeedView")

// MARK: - Transaction Section

private struct TransactionSection: Identifiable {
    let date: String
    let transactions: [Servicing.Transaction]
    var id: String { date }
}

// MARK: - Feed View

public struct FeedView: View {
    public init() {}

    @Dependency(\.transactionService) private var transactionService

    @State private var transactions: [Servicing.Transaction] = []
    @State private var isLoading = false
    @State private var isRefreshing = false
    @State private var errorMessage: String?
    @State private var nextToken: String?
    @State private var searchText = ""
    @State private var selectedTransactionIndex: Int = 0
    @State private var showingTransactionDetail = false

    private var groupedTransactions: [TransactionSection] {
        var sections: [TransactionSection] = []
        var currentDate = ""
        var currentTransactions: [Servicing.Transaction] = []

        for transaction in transactions {
            if transaction.fullDate != currentDate {
                if !currentTransactions.isEmpty {
                    sections.append(TransactionSection(date: currentDate, transactions: currentTransactions))
                }
                currentDate = transaction.fullDate
                currentTransactions = [transaction]
            } else {
                currentTransactions.append(transaction)
            }
        }

        if !currentTransactions.isEmpty {
            sections.append(TransactionSection(date: currentDate, transactions: currentTransactions))
        }

        return sections
    }

    public var body: some View {
        Group {
            if isLoading && transactions.isEmpty {
                loadingView
            } else if let error = errorMessage, transactions.isEmpty {
                errorView(error)
            } else if transactions.isEmpty {
                emptyView
            } else {
                transactionList
            }
        }
        .navigationTitle("Feed")
        .searchable(text: $searchText, prompt: "Search transactions")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if (isLoading || isRefreshing) && !transactions.isEmpty {
                    ProgressView()
                }
            }
        }
        .task {
            await loadTransactions()
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
            ForEach(groupedTransactions) { section in
                Section {
                    ForEach(section.transactions) { transaction in
                        Button {
                            if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
                                selectedTransactionIndex = index
                                showingTransactionDetail = true
                            }
                        } label: {
                            TransactionRow(transaction: transaction)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text(section.date)
                }
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
        .refreshable {
            await refreshNewTransactions()
        }
        .sheet(isPresented: $showingTransactionDetail) {
            TransactionDetailDrawer(
                transactions: transactions,
                currentIndex: $selectedTransactionIndex
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Data Loading

    private func loadTransactions() async {
        logger.info("loadTransactions started")
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
            logger.info("Phase 1 complete, count: \(result.transactions.count), hasMore: \(result.nextToken != nil)")

            isLoading = false

            if result.nextToken == nil && !result.transactions.isEmpty {
                await refreshNewTransactions()
            }
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Failed to load transactions: \(error.localizedDescription)")
            isLoading = false
        }

        logger.debug("loadTransactions completed")
    }

    private func refreshNewTransactions() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        logger.info("Checking for new transactions...")

        do {
            let result = try await transactionService.refreshTransactions(perPage: 50)
            transactions = result.transactions
            logger.info("Refresh complete, total count: \(result.transactions.count)")
        } catch {
            logger.error("Failed to refresh transactions: \(error.localizedDescription)")
        }

        isRefreshing = false
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
        }

        isLoading = false
    }
}
