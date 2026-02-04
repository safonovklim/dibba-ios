import Auth0
import Foundation
import os.log

private let logger = Logger(subsystem: "ai.dibba.ios", category: "Auth")

// MARK: - AuthUser

public struct AuthUser: Sendable {
    public let id: String
    public let name: String?
    public let email: String?
    public let emailVerified: String?
    public let picture: String?
    public let updatedAt: String?
    public let nickname: String?
    public let sub: String?

    public init(from user: UserInfo) {
        self.id = user.sub
        self.name = user.name
        self.email = user.email
        self.emailVerified = user.emailVerified.map { String($0) }
        self.picture = user.picture?.absoluteString
        self.updatedAt = user.updatedAt.map { ISO8601DateFormatter().string(from: $0) }
        self.nickname = user.nickname
        self.sub = user.sub
    }

    public var prettyJSON: String {
        let dict: [String: Any?] = [
            "id": id,
            "name": name,
            "email": email,
            "emailVerified": emailVerified,
            "picture": picture,
            "updatedAt": updatedAt,
            "nickname": nickname,
            "sub": sub,
        ]
        let filtered = dict.compactMapValues { $0 }
        if let data = try? JSONSerialization.data(withJSONObject: filtered, options: .prettyPrinted),
           let jsonString = String(data: data, encoding: .utf8)
        {
            return jsonString
        }
        return "{}"
    }
}

// MARK: - AuthenticationService

@MainActor
public final class AuthenticationService: ObservableObject, @unchecked Sendable {
    // MARK: Lifecycle

    public init() {
        self.credentialsManager = CredentialsManager(authentication: Auth0.authentication())
        logger.info("AuthenticationService initialized")
        Task {
            await checkAuthenticationStatus()
        }
    }

    // MARK: Public

    @Published public private(set) var isAuthenticated = false
    @Published public private(set) var user: AuthUser?
    @Published public private(set) var isLoading = false
    @Published public var errorMessage: String?

    public func checkAuthenticationStatus() async {
        logger.info("Checking authentication status...")
        isLoading = true
        defer { isLoading = false }

        do {
            let credentials = try await credentialsManager.credentials()
            logger.info("Found valid credentials, user is authenticated")
            isAuthenticated = true
            await fetchUserInfo(accessToken: credentials.accessToken)
        } catch {
            logger.info("No valid credentials found: \(error.localizedDescription)")
            isAuthenticated = false
            user = nil
        }
    }

    public func login() async {
        logger.info("Starting login...")
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
            logger.info("Login completed. isAuthenticated: \(self.isAuthenticated), error: \(self.errorMessage ?? "none")")
        }

        do {
            logger.info("Opening Auth0 WebAuth...")
            let credentials = try await Auth0
                .webAuth()
                .scope("openid profile email offline_access")
                .start()

            logger.info("WebAuth completed successfully, storing credentials...")
            let stored = credentialsManager.store(credentials: credentials)
            logger.info("Credentials stored: \(stored)")

            isAuthenticated = true
            logger.info("Set isAuthenticated = true")

            await fetchUserInfo(accessToken: credentials.accessToken)
            logger.info("User info fetched, login complete")
        } catch {
            logger.error("Login failed: \(error.localizedDescription)")
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
    }

    public func logout() async {
        logger.info("Starting logout...")
        isLoading = true
        defer { isLoading = false }

        do {
            try await Auth0.webAuth().clearSession()
            _ = credentialsManager.clear()
            isAuthenticated = false
            user = nil
            logger.info("Logout completed successfully")
        } catch {
            logger.error("Logout failed: \(error.localizedDescription)")
            errorMessage = "Logout failed: \(error.localizedDescription)"
        }
    }

    // MARK: Private

    private let credentialsManager: CredentialsManager

    private func fetchUserInfo(accessToken: String) async {
        logger.info("Fetching user info...")
        do {
            let userInfo = try await Auth0
                .authentication()
                .userInfo(withAccessToken: accessToken)
                .start()
            user = AuthUser(from: userInfo)
            logger.info("User info fetched: \(userInfo.email ?? "no email")")
        } catch {
            logger.error("Failed to fetch user info: \(error.localizedDescription)")
        }
    }
}

// MARK: - Shared Instance

public extension AuthenticationService {
    @MainActor static let shared = AuthenticationService()
}
