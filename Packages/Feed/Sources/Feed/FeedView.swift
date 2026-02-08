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
    @State private var searchText = ""
    @State private var selectedTransactionIndex: Int = 0
    @State private var showingTransactionDetail = false

    private var groupedTransactions: [TransactionSection] {
        let grouped = Dictionary(grouping: transactions) { $0.fullDate }
        var seen = Set<String>()
        var orderedDates: [String] = []
        for transaction in transactions {
            if seen.insert(transaction.fullDate).inserted {
                orderedDates.append(transaction.fullDate)
            }
        }
        return orderedDates.map { date in
            TransactionSection(date: date, transactions: grouped[date] ?? [])
        }
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

        // Show cached data immediately if available
        let cached = await transactionService.cachedTransactions
        if !cached.isEmpty {
            transactions = cached
            logger.info("Showing \(cached.count) cached transactions")
            await refreshNewTransactions()
            return
        }

        // No cache — fetch all pages, updating UI after each one
        isLoading = true
        errorMessage = nil

        do {
            var token: String? = nil
            repeat {
                let page = try await transactionService.fetchPage(nextToken: token, perPage: 100)
                transactions.append(contentsOf: page.transactions)
                token = page.nextToken
                logger.debug("Page loaded, showing \(transactions.count) transactions, hasMore: \(token != nil)")
            } while token != nil
        } catch {
            if transactions.isEmpty {
                errorMessage = error.localizedDescription
            }
            logger.error("Failed to load transactions: \(error.localizedDescription)")
        }

        isLoading = false
    }

    private func refreshNewTransactions() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        logger.info("Checking for new transactions...")

        do {
            let result = try await transactionService.refreshTransactions(perPage: 100)
            transactions = result.transactions
            logger.info("Refresh complete, total count: \(result.transactions.count)")
        } catch {
            logger.error("Failed to refresh transactions: \(error.localizedDescription)")
        }

        isRefreshing = false
    }
}
