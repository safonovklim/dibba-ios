//
//  ApiKeysState.swift
//  Data
//
//  Created by Klim on 10/11/25.
//
import Foundation
import Core

public struct ApiKeysState: Sendable {
    public var data: [ApiKey] = []
    public var error: Error?
    public var loaded: Bool = false
    public var loading: Bool = false
    
    public init() {}
}
