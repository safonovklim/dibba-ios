import Foundation

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

public protocol CoordinatorDelegate: AnyObject {
    func didFinish(coordinator: Coordinating)
}
