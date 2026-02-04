import Foundation

/// Represents the authentication state of the user
public enum AuthState: Sendable, Equatable {
    /// User is logged in anonymously (guest mode)
    case anonymous
    /// User is fully authenticated with Auth0
    case authenticated
    /// User is not authenticated at all
    case unauthenticated
}
