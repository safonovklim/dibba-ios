//
//  Profile.swift
//  Core
//
//  Created by Klim on 10/11/25.
//
import Foundation

public struct Profile: Codable, Sendable, Equatable, Hashable {
    public var goals: [String]
    public var occupation: [String]
    public var housing: [String]
    public var transport: [String]
    public var currency: String?
    public var age: String?
    public var notifyDailyReport: Bool
    public var notifyWeeklyReport: Bool
    public var notifyMonthlyReport: Bool
    public var notifyAnnualReport: Bool
    public var notifyNewRecommendation: Bool
    public var favoriteRealtimeVoice: String?
    public var createdAt: Date
    public var name: String
    public var email: String
    public var firstName: String
    public var lastName: String
    public var picture: String
    public var plan: String
    public var planStartsAt: Date?
    public var planExpiresAt: Date?
    
    public init(
        goals: [String],
        occupation: [String],
        housing: [String],
        transport: [String],
        currency: String?,
        age: String?,
        notifyDailyReport: Bool,
        notifyWeeklyReport: Bool,
        notifyMonthlyReport: Bool,
        notifyAnnualReport: Bool,
        notifyNewRecommendation: Bool,
        favoriteRealtimeVoice: String?,
        createdAt: Date,
        name: String,
        email: String,
        firstName: String,
        lastName: String,
        picture: String,
        plan: String,
        planStartsAt: Date?,
        planExpiresAt: Date?
    ) {
        self.goals = goals
        self.occupation = occupation
        self.housing = housing
        self.transport = transport
        self.currency = currency
        self.age = age
        self.notifyDailyReport = notifyDailyReport
        self.notifyWeeklyReport = notifyWeeklyReport
        self.notifyMonthlyReport = notifyMonthlyReport
        self.notifyAnnualReport = notifyAnnualReport
        self.notifyNewRecommendation = notifyNewRecommendation
        self.favoriteRealtimeVoice = favoriteRealtimeVoice
        self.createdAt = createdAt
        self.name = name
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.picture = picture
        self.plan = plan
        self.planStartsAt = planStartsAt
        self.planExpiresAt = planExpiresAt
    }
}
