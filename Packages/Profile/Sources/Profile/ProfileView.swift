import Auth
import SwiftUI

public struct ProfileView: View {
    // MARK: Lifecycle

    public init(
        authService: AuthenticationService = .shared,
        onLogout: (() -> Void)? = nil
    ) {
        self._authService = ObservedObject(wrappedValue: authService)
        self.onLogout = onLogout
    }

    // MARK: Public

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // User Profile Section
                    if let user = authService.user {
                        userProfileSection(user: user)
                    } else if authService.isAuthenticated {
                        loadingSection
                    } else {
                        notAuthenticatedSection
                    }

                    Divider()

                    // User JSON Details
                    if let user = authService.user {
                        userJSONSection(user: user)
                    }

                    Spacer(minLength: 32)

                    // Logout Button
                    if authService.isAuthenticated {
                        logoutButton
                    }
                }
                .padding()
            }
            .navigationTitle("Settings")
            .refreshable {
                await authService.checkAuthenticationStatus()
            }
        }
        .alert("Error", isPresented: .constant(authService.errorMessage != nil)) {
            Button("OK") { authService.errorMessage = nil }
        } message: {
            Text(authService.errorMessage ?? "")
        }
    }

    // MARK: Private

    @ObservedObject private var authService: AuthenticationService
    private let onLogout: (() -> Void)?

    @ViewBuilder
    private func userProfileSection(user: AuthUser) -> some View {
        VStack(spacing: 16) {
            // Profile Picture
            if let pictureURLString = user.picture,
               let pictureURL = URL(string: pictureURLString)
            {
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
    private var logoutButton: some View {
        Button(role: .destructive) {
            Task {
                await authService.logout()
                onLogout?()
            }
        } label: {
            HStack {
                if authService.isLoading {
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
        .disabled(authService.isLoading)
    }
}
