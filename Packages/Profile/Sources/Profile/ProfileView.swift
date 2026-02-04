import Auth
import Dependencies
import SwiftUI

public struct ProfileView: View {
    // MARK: Lifecycle

    public init(onLogout: (() -> Void)? = nil) {
        self.onLogout = onLogout
    }

    // MARK: Public

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // User Profile Section
                    if let user = user {
                        userProfileSection(user: user)
                    } else if authService.authState == .authenticated {
                        loadingSection
                    } else {
                        notAuthenticatedSection
                    }

                    Divider()

                    // User JSON Details
                    if let user = user {
                        userJSONSection(user: user)
                    }

                    // Account State Debug
                    accountStateSection

                    Spacer(minLength: 32)

                    // Logout Button
                    if authService.authState == .authenticated {
                        logoutButton
                    }
                }
                .padding()
            }
            .navigationTitle("Settings")
            .task {
                await loadUser()
            }
            .refreshable {
                await loadUser()
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: Private

    @Dependency(\.authService) private var authService
    @Dependency(\.accountManager) private var accountManager

    @State private var user: AuthUser?
    @State private var isLoading = false
    @State private var isLoggingOut = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var accountState: AccountState = .needAuthenticationAndOnboarding

    private let onLogout: (() -> Void)?

    private func loadUser() async {
        isLoading = true
        defer { isLoading = false }

        user = await authService.currentUser
        accountState = await accountManager.state
    }

    @ViewBuilder
    private func userProfileSection(user: AuthUser) -> some View {
        VStack(spacing: 16) {
            // Profile Picture
            if let pictureURL = user.picture {
                AsyncImage(url: pictureURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundStyle(.secondary)
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 2))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.secondary)
            }

            // Name
            if let name = user.name {
                Text(name)
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            // Email
            if let email = user.email {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(.secondary)
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Nickname
            if let nickname = user.nickname {
                Text("@\(nickname)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    @ViewBuilder
    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading user info...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    @ViewBuilder
    private var notAuthenticatedSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Not authenticated")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    @ViewBuilder
    private func userJSONSection(user: AuthUser) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundStyle(.blue)
                Text("User Details (JSON)")
                    .font(.headline)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                Text(user.prettyJSON)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var accountStateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.orange)
                Text("Account State")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Auth: \(String(describing: authService.authState))")
                    .font(.caption.monospaced())
                Text("Account: \(String(describing: accountState))")
                    .font(.caption.monospaced())
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var logoutButton: some View {
        Button(role: .destructive) {
            onLogout?()
        } label: {
            HStack {
                if isLoggingOut {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
        .disabled(isLoggingOut)
    }
}
