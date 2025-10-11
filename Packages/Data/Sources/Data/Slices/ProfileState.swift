//
//  ProfileState.swift
//  Data
//
//  Created by Klim on 10/11/25.
//
import Foundation
import Core

public struct ProfileState: Sendable {
    public var profile: Profile?
    public var identity: Identity?
    public var error: Error?
    public var loaded: Bool = false
    public var loading: Bool = false
    
    public init() {}
}

