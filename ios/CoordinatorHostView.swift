import Navigation
import SwiftUI
import UIKit

/// Hosts the UIKit-based AppCoordinator inside SwiftUI.
struct CoordinatorHostView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let coordinator = AppCoordinator()
        context.coordinator.appCoordinator = coordinator
        coordinator.start()
        return coordinator.rootNavigationController
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}

    func makeCoordinator() -> Holder {
        Holder()
    }

    final class Holder {
        var appCoordinator: AppCoordinator?
    }
}
