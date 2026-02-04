import Dependencies
import Foundation
import os.log

private let logger = Logger(subsystem: "ai.dibba.ios", category: "AccountManager")

// MARK: - Protocol

/// AccountManager combines authentication and onboarding state
/// to determine the overall account readiness
public protocol AccountManaging: Sendable {
    /// Whether the user is signed in (authenticated, not anonymous)
    var isSignedIn: Bool { get }

    /// The combined account state
    var state: AccountState { get async }

    /// Stream of account state changes
    var stateStream: AsyncStream<AccountState> { get }

    /// Mark onboarding as completed
    func markOnboardingComplete()

    /// Reset onboarding state (for testing or logout)
    func resetOnboardingState()

    /// Force a state update check
    func forceStateUpdate() async
}

// MARK: - Implementation

public final class AccountManager: AccountManaging, @unchecked Sendable {
    // MARK: Lifecycle

    public init() {
        // Create state stream
        let (stream, continuation) = AsyncStream<AccountState>.makeStream()
        self._stateStream = stream
        self._continuation = continuation

        logger.info("AccountManager initialized")

        // Subscribe to auth state changes
        subscribeToAuthState()
    }

    deinit {
        authStateTask?.cancel()
        _continuation.finish()
    }

    // MARK: Public

    @Dependency(\.authService) var authService

    public var isSignedIn: Bool {
        authService.authState == .authenticated
    }

    public var state: AccountState {
        get async {
            guard authService.authState != .unauthenticated else {
                return .needAuthenticationAndOnboarding
            }

            let onboardingFinished = isOnboardingFinished
            let signedIn = isSignedIn

            switch (onboardingFinished, signedIn) {
            case (true, true):
                return .userReady
            case (true, false):
                return .needAuthentication
            case (false, true):
                return .needOnboarding
            case (false, false):
                return .needAuthenticationAndOnboarding
            }
        }
    }

    public var stateStream: AsyncStream<AccountState> {
        _stateStream
    }

    public func markOnboardingComplete() {
        logger.info("Marking onboarding as complete")
        _isOnboardingFinished = true
        UserDefaults.standard.set(true, forKey: Self.onboardingCompletedKey)

        Task {
            await emitCurrentState()
        }
    }

    public func resetOnboardingState() {
        logger.info("Resetting onboarding state")
        _isOnboardingFinished = false
        UserDefaults.standard.removeObject(forKey: Self.onboardingCompletedKey)

        Task {
            await emitCurrentState()
        }
    }

    public func forceStateUpdate() async {
        await emitCurrentState()
    }

    // MARK: Private

    private static let onboardingCompletedKey = "ai.dibba.ios.onboardingCompleted"

    private var authStateTask: Task<Void, Never>?
    private let _stateStream: AsyncStream<AccountState>
    private let _continuation: AsyncStream<AccountState>.Continuation

    private var _isOnboardingFinished: Bool = {
        UserDefaults.standard.bool(forKey: AccountManager.onboardingCompletedKey)
    }()

    private var isOnboardingFinished: Bool {
        _isOnboardingFinished
    }

    private func subscribeToAuthState() {
        authStateTask = Task { [weak self] in
            guard let self else { return }

            for await authState in authService.authStateStream {
                logger.info("Auth state changed: \(String(describing: authState))")

                if authState == .unauthenticated {
                    // User logged out - reset onboarding for clean state
                    // (optional: you might want to keep onboarding state)
                }

                await emitCurrentState()
            }
        }
    }

    private func emitCurrentState() async {
        let currentState = await state
        logger.info("Emitting account state: \(String(describing: currentState))")
        _continuation.yield(currentState)
    }
}

// MARK: - Dependency Registration

extension AccountManager: DependencyKey {
    public static let liveValue: any AccountManaging = AccountManager()
}

public extension DependencyValues {
    var accountManager: any AccountManaging {
        get { self[AccountManager.self] }
        set { self[AccountManager.self] = newValue }
    }
}
