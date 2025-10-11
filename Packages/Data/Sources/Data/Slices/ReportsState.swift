//
//  ReportsState.swift
//  Data
//
//  Created by Klim on 10/11/25.
//

import Foundation
import Core

public struct ReportsState: Sendable {
    public var data: [Report] = []
    public var error: Error?
    public var loaded: Bool = false
    public var loading: Bool = false
    
    public init() {}
}
