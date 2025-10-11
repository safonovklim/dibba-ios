//
//  TargetsState.swift
//  Data
//
//  Created by Klim on 10/11/25.
//

import Foundation
import Core

public struct TargetsState: Sendable {
    public var data: [Target] = []
    public var idForDrawer: String?
    public var error: Error?
    public var creationError: Error?
    public var loaded: Bool = false
    public var loading: Bool = false
    
    public init() {}
}

