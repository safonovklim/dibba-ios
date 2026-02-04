import Foundation

@MainActor
public protocol CompositionCoordinating: Coordinating, CoordinatorDelegate {
    var children: [Coordinating] { get set }
}

public extension CompositionCoordinating {
    func add(_ coordinator: Coordinating) {
        children.append(coordinator)
        coordinator.delegate = self
    }

    func remove(_ coordinator: Coordinating) {
        children.removeAll { $0 === coordinator }
    }

    // MARK: - CoordinatorDelegate

    func didFinish(coordinator: Coordinating) {
        remove(coordinator)
    }
}
