import Navigation
import SwiftUI
import UIKit

@MainActor
public final class OnboardingFlow: NavigationFlowCoordinating {
    // MARK: Lifecycle

    public init(
        rootNavigationController: UINavigationController,
        onFinish: @escaping () -> Void
    ) {
        self.rootNavigationController = rootNavigationController
        self.onFinish = onFinish
    }

    // MARK: Public

    public weak var delegate: CoordinatorDelegate?
    public var child: Coordinating?
    public let rootNavigationController: UINavigationController

    public func start() {
        let view = OnboardingScreen {
            self.finish()
            self.onFinish()
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

    private let onFinish: () -> Void
}

private struct OnboardingScreen: View {
    var onFinish: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            OnboardingView()
            Button("Finish Onboarding") { onFinish() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
