import Foundation

/// Represents the combined account state (auth + onboarding)
public enum AccountState: Sendable, Equatable {
    /// User needs to authenticate and complete onboarding
    case needAuthenticationAndOnboarding
    /// User is authenticated but needs to complete onboarding
    case needOnboarding
    /// User has completed onboarding but needs to re-authenticate
    case needAuthentication
    /// User is fully ready - authenticated and onboarded
    case userReady
}
