import Foundation

@MainActor
public protocol Coordinating: AnyObject {
    func start()
    func finish()

    var delegate: CoordinatorDelegate? { get set }
}

public extension Coordinating {
    func finish() {
        delegate?.didFinish(coordinator: self)
    }
}

@MainActor
public protocol CoordinatorDelegate: AnyObject {
    func didFinish(coordinator: Coordinating)
}
