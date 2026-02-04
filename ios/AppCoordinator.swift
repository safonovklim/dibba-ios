import Auth
import Dashboard
import Navigation
import Onboarding
import os.log
import UIKit

private let logger = Logger(subsystem: "ai.dibba.ios", category: "AppCoordinator")

// MARK: - Root App Flow

@MainActor
final class AppCoordinator: NavigationFlowCoordinating {
    // MARK: Lifecycle

    init(rootNavigationController: UINavigationController) {
        self.rootNavigationController = rootNavigationController
        self.authService = AuthenticationService.shared
        logger.info("AppCoordinator initialized")
    }

    convenience init() {
        self.init(rootNavigationController: UINavigationController())
    }

    // MARK: Internal

    weak var delegate: CoordinatorDelegate?
    var child: Coordinating?

    let rootNavigationController: UINavigationController

    func start() {
        logger.info("AppCoordinator.start()")
        // Check if already authenticated on app launch
        Task {
            await authService.checkAuthenticationStatus()
            logger.info("Auth check complete. isAuthenticated: \(self.authService.isAuthenticated)")
            if authService.isAuthenticated {
                // Skip auth and onboarding if already logged in
                startHome()
            } else {
                startAuthFlow()
            }
        }
    }

    // MARK: Private

    private let authService: AuthenticationService

    private func startAuthFlow() {
        logger.info("startAuthFlow()")
        let auth = AuthFlow(
            rootNavigationController: rootNavigationController,
            authService: authService,
            onAuthenticated: { [weak self] in
                logger.info("onAuthenticated callback - self is \(self == nil ? "nil" : "valid")")
                self?.startOnboardingFlow()
            }
        )
        add(child: auth)
        auth.start()
    }

    private func startOnboardingFlow() {
        logger.info("startOnboardingFlow()")
        let onboarding = OnboardingFlow(
            rootNavigationController: rootNavigationController,
            onFinish: { [weak self] in
                logger.info("onFinish callback from onboarding")
                self?.startHome()
            }
        )
        add(child: onboarding)
        onboarding.start()
        logger.info("OnboardingFlow started")
    }

    private func startHome() {
        logger.info("startHome()")
        let tabBarCoordinator = TabBarCoordinator(
            authService: authService,
            onLogout: { [weak self] in
                self?.handleLogout()
            }
        )
        add(child: tabBarCoordinator)
        tabBarCoordinator.start()
        rootNavigationController.setViewControllers(
            [tabBarCoordinator.tabBarController],
            animated: true
        )
        logger.info("TabBarCoordinator set as root")
    }

    private func handleLogout() {
        logger.info("handleLogout()")
        // Clear the child coordinator and return to auth flow
        removeChild()
        startAuthFlow()
    }
}
