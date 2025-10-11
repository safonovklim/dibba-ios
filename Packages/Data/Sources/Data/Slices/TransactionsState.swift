//
//  TransactionsState.swift
//  Data
//
//  Created by Klim on 10/11/25.
//

import Foundation
import Core

public struct TransactionsState: Sendable {
    public var data: [Transaction] = []
    public var nextToken: String?
    public var error: Error?
    public var creationError: Error?
    public var updateError: Error?
    public var bulkLoaded: Bool = false
    public var loaded: Bool = false
    public var loading: Bool = false
    
    public init() {}
}
