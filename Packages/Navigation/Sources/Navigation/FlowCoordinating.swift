import Foundation

@MainActor
public protocol FlowCoordinating: Coordinating, CoordinatorDelegate {
    var child: Coordinating? { get set }
}

public extension FlowCoordinating {
    func add(child coordinator: Coordinating) {
        child = coordinator
        child?.delegate = self
    }

    func removeChild() {
        child?.delegate = nil
        child = nil
    }

    // MARK: - CoordinatorDelegate

    func didFinish(coordinator _: Coordinating) {
        removeChild()
    }
}
