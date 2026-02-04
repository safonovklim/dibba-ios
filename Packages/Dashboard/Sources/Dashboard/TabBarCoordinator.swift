import Auth
import Feed
import Navigation
import Profile
import SwiftUI
import UIKit

@MainActor
public final class TabBarCoordinator: CompositionCoordinating {
    // MARK: Lifecycle

    public init(
        authService: AuthenticationService = .shared,
        onLogout: (() -> Void)? = nil
    ) {
        self.authService = authService
        self.onLogout = onLogout
    }

    // MARK: Public

    public weak var delegate: CoordinatorDelegate?
    public var children: [Coordinating] = []
    public let tabBarController = UITabBarController()

    public func start() {
        let dashboardNav = makeNavController(
            root: DashboardView().wrapped(),
            title: "Dashboard",
            systemImage: "rectangle.grid.2x2"
        )

        let feedNav = makeNavController(
            root: FeedView().wrapped(),
            title: "Feed",
            systemImage: "dot.radiowaves.left.and.right"
        )

        let profileNav = makeNavController(
            root: ProfileView(authService: authService, onLogout: onLogout).wrapped(),
            title: "Settings",
            systemImage: "gearshape.fill"
        )

        tabBarController.viewControllers = [
            dashboardNav,
            feedNav,
            profileNav,
        ]
        tabBarController.selectedIndex = 0
    }

    public func didFinish(coordinator: Coordinating) {
        remove(coordinator)
    }

    // MARK: Private

    private let authService: AuthenticationService
    private let onLogout: (() -> Void)?

    private func makeNavController(
        root: UIViewController,
        title: String,
        systemImage: String
    ) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: systemImage),
            tag: 0
        )
        return nav
    }
}
