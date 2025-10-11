//
//  TransactionApiInput.swift
//  Core
//
//  Created by Klim on 10/11/25.
//

import Foundation


public struct TransactionApiInput: Codable, Sendable, Equatable, Hashable {
    public var text: String?
    public var amount: String?
    public var merchant: String?
    public var card: String?
    public var from: String?
    public var location: String?
    public init(
        text: String? = nil,
        amount: String? = nil,
        merchant: String? = nil,
        card: String? = nil,
        from: String? = nil,
        location: String? = nil
    ) {
        self.text = text
        self.amount = amount
        self.merchant = merchant
        self.card = card
        self.from = from
        self.location = location
    }
}

