//
//  TransactionMetadata.swift
//  Core
//
//  Created by Klim on 10/11/25.
//

import Foundation


public struct TransactionMetadata: Codable, Sendable, Equatable, Hashable {
    public struct RequestIdentity: Codable, Sendable, Equatable, Hashable {
        public var userAgent: String
        public var ipAddress: String
        public init(userAgent: String, ipAddress: String) {
            self.userAgent = userAgent
            self.ipAddress = ipAddress
        }
    }
    public var type: String
    public var identity: RequestIdentity
    public init(type: String, identity: RequestIdentity) {
        self.type = type
        self.identity = identity
    }
}
