import SwiftUI
import UIKit

/// UIHostingController wrapper that can hide the navigation bar for SwiftUI screens.
@MainActor
public final class HostingController<Content: View>: UIHostingController<Content> {
    let isNavBarHidden: Bool

    public init(rootView: Content, isNavBarHidden: Bool = false) {
        self.isNavBarHidden = isNavBarHidden
        super.init(rootView: rootView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(
            isNavBarHidden,
            animated: animated
        )
    }
}
