import Dependencies
import Foundation
import os.log

private let logger = Logger(subsystem: "ai.dibba.ios", category: "FirstLaunchService")

// MARK: - Protocol

/// Service to handle first app launch scenarios
/// Handles clearing stale auth from previous installs
public protocol FirstLaunchServicing: Sendable {
    /// Whether this is the first launch after install/reinstall
    var isFirstLaunch: Bool { get }

    /// Handle first launch if needed - clears stale auth
    func handleFirstLaunchIfNeeded() async
}

// MARK: - Implementation

public final class FirstLaunchService: FirstLaunchServicing, @unchecked Sendable {
    // MARK: Lifecycle

    public init() {
        logger.info("FirstLaunchService initialized")
    }

    // MARK: Public

    @Dependency(\.authService) var authService
    @Dependency(\.appResetService) var appResetService

    public var isFirstLaunch: Bool {
        !UserDefaults.standard.bool(forKey: Self.hasLaunchedKey)
    }

    public func handleFirstLaunchIfNeeded() async {
        logger.info("handleFirstLaunchIfNeeded - isFirstLaunch: \(self.isFirstLaunch)")

        guard isFirstLaunch else {
            logger.info("Not first launch, skipping")
            return
        }

        // Check if we have stale auth from a previous install
        let hasStaleAuth = authService.authState != .unauthenticated

        if hasStaleAuth {
            logger.info("Found stale auth credentials from previous install, clearing...")

            // Clear auth credentials
            authService.clearCredentials()

            // Reset all app state
            do {
                try await appResetService.resetAllState()
            } catch {
                logger.error("Failed to reset state: \(error.localizedDescription)")
            }

            // Re-check auth status
            await authService.checkAuthenticationStatus()

            logger.info("Stale auth cleared")
        }

        // Mark as launched
        UserDefaults.standard.set(true, forKey: Self.hasLaunchedKey)
        logger.info("First launch handled, marked as launched")
    }

    // MARK: Private

    private static let hasLaunchedKey = "ai.dibba.ios.hasLaunched"
}

// MARK: - Dependency Registration

extension FirstLaunchService: DependencyKey {
    public static let liveValue: any FirstLaunchServicing = FirstLaunchService()
}

public extension DependencyValues {
    var firstLaunchService: any FirstLaunchServicing {
        get { self[FirstLaunchService.self] }
        set { self[FirstLaunchService.self] = newValue }
    }
}
