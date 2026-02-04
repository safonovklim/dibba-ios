import UIKit

@MainActor
public protocol NavigationFlowCoordinating: FlowCoordinating {
    var rootNavigationController: UINavigationController { get }
}
