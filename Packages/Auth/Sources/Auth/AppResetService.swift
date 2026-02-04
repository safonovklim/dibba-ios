import Dependencies
import Foundation
import os.log

private let logger = Logger(subsystem: "ai.dibba.ios", category: "AppResetService")

// MARK: - StateResetting Protocol

/// Protocol for services that can reset their state
public protocol StateResetting: Sendable {
    func resetState() async throws
}

// MARK: - AppResetService Protocol

/// Service that coordinates resetting all app state on logout
public protocol AppResetting: Sendable {
    /// Register a service that should be reset on logout
    func register(_ resetter: any StateResetting)

    /// Reset all registered services
    func resetAllState() async throws
}

// MARK: - Implementation

public final class AppResetService: AppResetting, @unchecked Sendable {
    // MARK: Lifecycle

    public init() {
        logger.info("AppResetService initialized")
    }

    // MARK: Public

    public func register(_ resetter: any StateResetting) {
        resettersLock.withLock {
            resetters.append(resetter)
        }
        logger.info("Registered state resetter: \(type(of: resetter))")
    }

    public func resetAllState() async throws {
        logger.info("Resetting all state...")

        let currentResetters: [any StateResetting] = resettersLock.withLock {
            resetters
        }

        // Reset all services in parallel
        try await withThrowingTaskGroup(of: Void.self) { group in
            for resetter in currentResetters {
                group.addTask {
                    try await resetter.resetState()
                }
            }
            try await group.waitForAll()
        }

        logger.info("All state reset completed")
    }

    // MARK: Private

    private var resetters: [any StateResetting] = []
    private let resettersLock = NSLock()
}

// MARK: - Dependency Registration

extension AppResetService: DependencyKey {
    public static let liveValue: any AppResetting = AppResetService()
}

public extension DependencyValues {
    var appResetService: any AppResetting {
        get { self[AppResetService.self] }
        set { self[AppResetService.self] = newValue }
    }
}

// MARK: - AccountManager + StateResetting

extension AccountManager: StateResetting {
    public func resetState() async throws {
        resetOnboardingState()
    }
}
