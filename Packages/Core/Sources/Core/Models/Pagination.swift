//
//  Pagination.swift
//  Core
//
//  Created by Klim on 10/11/25.
//

import Foundation

public struct Page<T: Codable & Sendable>: Codable, Sendable {
    public var items: [T]
    public var nextToken: String?
    
    public init(items: [T], nextToken: String?) {
        self.items = items
        self.nextToken = nextToken
    }
    
    public func appending(_ newItems: [T], nextToken: String?) -> Page<T> {
        Page(items: self.items + newItems, nextToken: nextToken)
    }
}
