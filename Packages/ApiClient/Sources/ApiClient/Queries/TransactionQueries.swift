import Foundation

// MARK: - Transaction Queries

public enum TransactionQueries {
    private static let transactionFields = """
        error_message
        name
        amount
        currency
        created_at
        is_atm
        is_purchase
        is_transfer
        is_credit
        is_debit
        full_date
        card_number
        account_number
        org_name
        org_type
        success
        transaction_type
        merchant_category
        id
        input { from location text }
        metadata { type identity { ipAddress userAgent } }
        """

    public static let listTransactions = """
        query listTransactions($nextToken: String, $perPage: Int) {
            listTransactions(nextToken: $nextToken, perPage: $perPage) {
                list {
                    \(transactionFields)
                }
                nextToken
            }
        }
        """

    public static let createTransaction = """
        mutation createTransaction($input: TransactionManualInput!) {
            createTransaction(input: $input) {
                \(transactionFields)
            }
        }
        """

    public static let updateTransaction = """
        mutation updateTransaction($id: String!, $input: TransactionEditInput!) {
            updateTransaction(id: $id, input: $input) {
                \(transactionFields)
            }
        }
        """

    public static let deleteTransaction = """
        mutation deleteTransaction($id: String!) {
            deleteTransaction(id: $id) {
                success
                message
            }
        }
        """
}
