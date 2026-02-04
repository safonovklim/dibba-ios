import Auth0
import Foundation

/// Represents the authenticated user's profile information
public struct AuthUser: Sendable, Equatable {
    public let id: String
    public let name: String?
    public let email: String?
    public let emailVerified: Bool?
    public let picture: URL?
    public let updatedAt: Date?
    public let nickname: String?

    public init(
        id: String,
        name: String? = nil,
        email: String? = nil,
        emailVerified: Bool? = nil,
        picture: URL? = nil,
        updatedAt: Date? = nil,
        nickname: String? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.emailVerified = emailVerified
        self.picture = picture
        self.updatedAt = updatedAt
        self.nickname = nickname
    }

    public init(from userInfo: UserInfo) {
        self.id = userInfo.sub
        self.name = userInfo.name
        self.email = userInfo.email
        self.emailVerified = userInfo.emailVerified
        self.picture = userInfo.picture
        self.updatedAt = userInfo.updatedAt
        self.nickname = userInfo.nickname
    }

    public var prettyJSON: String {
        let dict: [String: Any?] = [
            "id": id,
            "name": name,
            "email": email,
            "emailVerified": emailVerified,
            "picture": picture?.absoluteString,
            "updatedAt": updatedAt.map { ISO8601DateFormatter().string(from: $0) },
            "nickname": nickname,
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
