import Auth
import Dependencies
import os.log
import Servicing
import SwiftUI

private let logger = Logger(subsystem: "ai.dibba.ios", category: "ProfileView")

public struct ProfileView: View {
    // MARK: Lifecycle

    public init(onLogout: (() -> Void)? = nil) {
        self.onLogout = onLogout
    }

    // MARK: Public

    public var body: some View {
        let _ = logger.debug("body rendered - profile: \(profile != nil), isLoadingProfile: \(isLoadingProfile), user: \(user != nil), isLoadingUser: \(isLoadingUser)")
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // User Profile Section (from backend)
                    if let profile = profile {
                        let _ = logger.debug("Rendering profileSection")
                        profileSection(profile: profile)
                    } else if isLoadingProfile {
                        let _ = logger.debug("Rendering loading state for profile")
                        loadingSection(text: "Loading profile...")
                    } else {
                        let _ = logger.debug("Profile section not rendered - profile is nil and not loading")
                    }

                    // Auth0 User Section
                    if let user = user {
                        auth0UserSection(user: user)
                    } else if authService.authState == .authenticated && !isLoadingUser {
                        loadingSection(text: "Loading user...")
                    } else if authService.authState != .authenticated {
                        notAuthenticatedSection
                    }

                    Divider()

                    // Subscription Section
                    if let profile = profile {
                        subscriptionSection(profile: profile)
                    }

                    // Notification Preferences
                    if let profile = profile {
                        notificationSection(profile: profile)
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
                await loadData()
            }
            .refreshable {
                await loadData(force: true)
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
    @Dependency(\.profileService) private var profileService

    @State private var user: AuthUser?
    @State private var profile: Servicing.Profile?
    @State private var isLoadingUser = false
    @State private var isLoadingProfile = false
    @State private var isLoggingOut = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var accountState: AccountState = .needAuthenticationAndOnboarding

    private let onLogout: (() -> Void)?

    private func loadData(force: Bool = false) async {
        logger.info("loadData started, force: \(force)")
        async let userTask: () = loadUser()
        async let profileTask: () = loadProfile(force: force)
        _ = await (userTask, profileTask)
        logger.info("loadData completed")
    }

    private func loadUser() async {
        logger.debug("loadUser started")
        isLoadingUser = true
        defer {
            isLoadingUser = false
            logger.debug("loadUser completed, isLoadingUser: false")
        }

        user = await authService.currentUser
        accountState = await accountManager.state
        logger.info("User loaded: \(user?.name ?? "nil"), accountState: \(String(describing: accountState))")
    }

    private func loadProfile(force: Bool = false) async {
        logger.debug("loadProfile started, force: \(force)")
        isLoadingProfile = true
        defer {
            isLoadingProfile = false
            logger.debug("loadProfile completed, isLoadingProfile: false")
        }

        do {
            profile = try await profileService.getProfile(force: force)
            logger.info("Profile loaded successfully: \(profile?.displayName ?? "nil"), plan: \(profile?.plan.rawValue ?? "nil")")
        } catch {
            logger.error("Profile loading failed: \(error.localizedDescription)")
            // Profile loading failed - show Auth0 user info only
        }
    }

    @ViewBuilder
    private func profileSection(profile: Servicing.Profile) -> some View {
        VStack(spacing: 16) {
            // Profile Picture
            if let pictureURL = profile.pictureURL {
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
            if !profile.displayName.isEmpty {
                Text(profile.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            // Email
            if !profile.email.isEmpty {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(.secondary)
                    Text(profile.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Currency & Age
            HStack(spacing: 16) {
                if let currency = profile.currency {
                    Label(currency, systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let age = profile.age {
                    Label(age, systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Member Since
            Text("Member since \(formattedDate(profile.createdAt))")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    @ViewBuilder
    private func auth0UserSection(user: AuthUser) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.badge.key")
                    .foregroundStyle(.blue)
                Text("Auth0 User")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                if let name = user.name {
                    infoRow(label: "Name", value: name)
                }
                if let email = user.email {
                    infoRow(label: "Email", value: email)
                }
                if let nickname = user.nickname {
                    infoRow(label: "Nickname", value: "@\(nickname)")
                }
                infoRow(label: "User ID", value: user.id)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func subscriptionSection(profile: Servicing.Profile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.circle.fill")
                    .foregroundStyle(profile.isPremium ? .yellow : .secondary)
                Text("Subscription")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Plan")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(profile.plan.displayName)
                        .fontWeight(.medium)
                        .foregroundStyle(profile.isPremium ? .yellow : .primary)
                }

                if let expiresAt = profile.planExpiresAt {
                    HStack {
                        Text("Expires")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(formattedDate(expiresAt))
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func notificationSection(profile: Servicing.Profile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(.orange)
                Text("Notifications")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                notificationRow("Daily Report", enabled: profile.notifyDailyReport)
                notificationRow("Weekly Report", enabled: profile.notifyWeeklyReport)
                notificationRow("Monthly Report", enabled: profile.notifyMonthlyReport)
                notificationRow("Annual Report", enabled: profile.notifyAnnualReport)
                notificationRow("Recommendations", enabled: profile.notifyNewRecommendation)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func notificationRow(_ label: String, enabled: Bool) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Image(systemName: enabled ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(enabled ? .green : .secondary)
        }
    }

    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.system(.body, design: .monospaced))
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .font(.caption)
    }

    @ViewBuilder
    private func loadingSection(text: String) -> some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(text)
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
