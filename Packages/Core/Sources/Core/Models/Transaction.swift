//
//  Transaction.swift
//  Core
//
//  Created by Klim on 10/11/25.
//
import Foundation


public struct Transaction: Identifiable, Codable, Sendable, Equatable, Hashable {
    public var id: String
    public var accountNumber: String
    public var cardNumber: String
    public var name: String
    public var merchantCategory: String
    public var amount: Decimal
    public var currency: String
    public var success: Bool
    public var isCredit: Bool
    public var isDebit: Bool
    public var isAtm: Bool
    public var isPurchase: Bool
    public var isTransfer: Bool
    public var fullDate: String
    public var orgType: String
    public var orgName: String
    public var transactionType: String
    public var errorMessage: String
    public var input: TransactionApiInput
    public var metadata: TransactionMetadata
    public var createdAt: Date

    public init(
        id: String,
        accountNumber: String,
        cardNumber: String,
        name: String,
        merchantCategory: String,
        amount: Decimal,
        currency: String,
        success: Bool,
        isCredit: Bool,
        isDebit: Bool,
        isAtm: Bool,
        isPurchase: Bool,
        isTransfer: Bool,
        fullDate: String,
        orgType: String,
        orgName: String,
        transactionType: String,
        errorMessage: String,
        input: TransactionApiInput,
        metadata: TransactionMetadata,
        createdAt: Date
    ) {
        self.id = id
        self.accountNumber = accountNumber
        self.cardNumber = cardNumber
        self.name = name
        self.merchantCategory = merchantCategory
        self.amount = amount
        self.currency = currency
        self.success = success
        self.isCredit = isCredit
        self.isDebit = isDebit
        self.isAtm = isAtm
        self.isPurchase = isPurchase
        self.isTransfer = isTransfer
        self.fullDate = fullDate
        self.orgType = orgType
        self.orgName = orgName
        self.transactionType = transactionType
        self.errorMessage = errorMessage
        self.input = input
        self.metadata = metadata
        self.createdAt = createdAt
    }
}
