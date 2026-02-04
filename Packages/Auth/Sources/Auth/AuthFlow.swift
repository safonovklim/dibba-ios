import Navigation
import os.log
import SwiftUI
import UIKit

private let logger = Logger(subsystem: "ai.dibba.ios", category: "AuthFlow")

@MainActor
public final class AuthFlow: NavigationFlowCoordinating {
    // MARK: Lifecycle

    public init(
        rootNavigationController: UINavigationController,
        authService: AuthenticationService = .shared,
        onAuthenticated: @escaping () -> Void
    ) {
        self.rootNavigationController = rootNavigationController
        self.authService = authService
        self.onAuthenticated = onAuthenticated
        logger.info("AuthFlow initialized")
    }

    // MARK: Public

    public weak var delegate: CoordinatorDelegate?
    public var child: Coordinating?
    public let rootNavigationController: UINavigationController

    public func start() {
        logger.info("AuthFlow.start() - isAuthenticated: \(self.authService.isAuthenticated)")

        // Check if already authenticated
        if authService.isAuthenticated {
            logger.info("Already authenticated, skipping to onAuthenticated")
            finish()
            onAuthenticated()
            return
        }

        logger.info("Showing LoginScreen")
        let view = LoginScreen(authService: authService) { [weak self] in
            logger.info("LoginScreen onLogin callback triggered - self is \(self == nil ? "nil" : "valid")")
            guard let self = self else {
                logger.error("AuthFlow self is nil - cannot proceed!")
                return
            }
            logger.info("Calling finish()")
            self.finish()
            logger.info("Calling onAuthenticated()")
            self.onAuthenticated()
            logger.info("onAuthenticated() returned")
        }
        rootNavigationController.setViewControllers(
            [view.wrapped(hideNavBar: true)],
            animated: true
        )
    }

    public func didFinish(coordinator _: Coordinating) {
        removeChild()
    }

    // MARK: Private

    private let authService: AuthenticationService
    private let onAuthenticated: () -> Void
}

// MARK: - LoginScreen

private struct LoginScreen: View {
    @ObservedObject var authService: AuthenticationService
    var onLogin: () -> Void

    @State private var showingError = false
    @State private var debugLog: [String] = []

    var body: some View {
        VStack(spacing: 20) {
            // App Logo
            Image(systemName: "shield.checkered")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Dibba")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Debug info box
            VStack(alignment: .leading, spacing: 4) {
                Text("DEBUG LOG:")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
                Text("isAuthenticated: \(authService.isAuthenticated ? "YES" : "NO")")
                    .font(.caption.monospaced())
                Text("isLoading: \(authService.isLoading ? "YES" : "NO")")
                    .font(.caption.monospaced())
                Text("error: \(authService.errorMessage ?? "none")")
                    .font(.caption.monospaced())
                    .lineLimit(2)

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(debugLog, id: \.self) { line in
                            Text(line)
                                .font(.system(size: 10, design: .monospaced))
                        }
                    }
                }
                .frame(maxHeight: 100)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.05))
            .cornerRadius(8)

            Spacer()

            // Login Button
            if authService.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(height: 50)
                Text("Loading...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Button {
                    Task {
                        addLog("Button tapped")
                        addLog("Calling login()...")
                        await authService.login()
                        addLog("login() returned")
                        addLog("isAuthenticated: \(authService.isAuthenticated)")
                        if authService.isAuthenticated {
                            addLog("SUCCESS - calling onLogin")
                            onLogin()
                        } else {
                            addLog("FAILED - not authenticated")
                            if let error = authService.errorMessage {
                                addLog("Error: \(error)")
                                showingError = true
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.badge.key.fill")
                        Text("Sign in with Auth0")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
                .frame(height: 40)
        }
        .padding(.horizontal, 32)
        .alert("Error", isPresented: $showingError) {
            Button("OK") {
                authService.errorMessage = nil
            }
        } message: {
            Text(authService.errorMessage ?? "Unknown error")
        }
        .onChange(of: authService.errorMessage) { _, newValue in
            if newValue != nil {
                showingError = true
            }
        }
        .onAppear {
            addLog("Screen appeared")
        }
    }

    private func addLog(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        debugLog.append("[\(timestamp)] \(message)")
    }
}
