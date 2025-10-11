//
//  ReportSum.swift
//  Core
//
//  Created by Klim on 10/11/25.
//

import Foundation

public struct ReportSum: Codable, Sendable, Equatable, Hashable {
    public var total: Decimal
    public var diff: Decimal
    public var transfer: Decimal
    public var purchase: Decimal
    public var atm: Decimal
    public var credit: Decimal
    public var debit: Decimal
    
    public init(
        total: Decimal,
        diff: Decimal,
        transfer: Decimal,
        purchase: Decimal,
        atm: Decimal,
        credit: Decimal,
        debit: Decimal
    ) {
        self.total = total
        self.diff = diff
        self.transfer = transfer
        self.purchase = purchase
        self.atm = atm
        self.credit = credit
        self.debit = debit
    }
}
