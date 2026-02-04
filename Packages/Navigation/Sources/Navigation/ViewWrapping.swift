import SwiftUI
import UIKit

public extension View {
    /// Wrap the SwiftUI view in a HostingController so it can be pushed by UIKit coordinators.
    func wrapped(hideNavBar: Bool = false) -> UIViewController {
        HostingController(rootView: self, isNavBarHidden: hideNavBar)
    }
}
