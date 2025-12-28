import SwiftUI
import Auth
import Dashboard
import Feed
import Navigation
import Onboarding
import Profile

struct AppCoordinatorView: View {
	enum Route: String, CaseIterable, Identifiable {
		case login
		case onboarding
		case dashboard
		case feed
		case settings

		var id: String { rawValue }
	}

	@State private var route: Route = .login

	var body: some View {
		VStack(spacing: 16) {
			Group {
				switch route {
					case .login:
						LoginView()
					case .onboarding:
						OnboardingView()
					case .dashboard:
						DashboardView()
					case .feed:
						FeedView()
					case .settings:
						ProfileView()
				}
			}
			.frame(maxHeight: .infinity)

			HStack {
				ForEach(Route.allCases) { item in
					Button(item.rawValue.capitalized) {
						route = item
					}
					.buttonStyle(.borderedProminent)
				}
			}
		}
		.padding()
	}
}

#Preview {
	AppCoordinatorView()
}
