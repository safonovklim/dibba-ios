import Foundation

// MARK: - API Client Error

public enum APIClientError: Error, Sendable, Equatable {
    case client(_ error: URLError)
    case http(_ statusCode: Int)
    case unauthorized
    case graphQLErrors(_ errors: [GraphQLError])
    case decodingError(_ message: String)
    case noData
    case unknown(_ message: String)

    public static func == (lhs: APIClientError, rhs: APIClientError) -> Bool {
        switch (lhs, rhs) {
        case let (.client(l), .client(r)): l.code == r.code
        case let (.http(l), .http(r)): l == r
        case (.unauthorized, .unauthorized): true
        case let (.graphQLErrors(l), .graphQLErrors(r)): l == r
        case let (.decodingError(l), .decodingError(r)): l == r
        case (.noData, .noData): true
        case let (.unknown(l), .unknown(r)): l == r
        default: false
        }
    }
}

// MARK: - LocalizedError

extension APIClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .client(error):
            "Network error: \(error.localizedDescription)"
        case let .http(statusCode):
            "HTTP error: \(statusCode)"
        case .unauthorized:
            "Unauthorized. Please sign in again."
        case let .graphQLErrors(errors):
            errors.first?.message ?? "GraphQL error"
        case let .decodingError(message):
            "Failed to parse response: \(message)"
        case .noData:
            "No data received from server"
        case let .unknown(message):
            "Unknown error: \(message)"
        }
    }
}

// MARK: - GraphQL Error

public struct GraphQLError: Codable, Sendable, Equatable {
    public let message: String
    public let errorType: String?
    public let path: [String]?
    public let extensions: [String: String]?

    public init(
        message: String,
        errorType: String? = nil,
        path: [String]? = nil,
        extensions: [String: String]? = nil
    ) {
        self.message = message
        self.errorType = errorType
        self.path = path
        self.extensions = extensions
    }

    enum CodingKeys: String, CodingKey {
        case message
        case errorType
        case path
        case extensions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        errorType = try container.decodeIfPresent(String.self, forKey: .errorType)
        path = try container.decodeIfPresent([String].self, forKey: .path)
        extensions = try container.decodeIfPresent([String: String].self, forKey: .extensions)
    }
}

// MARK: - Error Handling Helpers

extension APIClientError {
    public var isUnauthorized: Bool {
        switch self {
        case .unauthorized: true
        case .http(401): true
        case let .graphQLErrors(errors):
            errors.contains { $0.errorType == "401" || $0.errorType == "UNAUTHORIZED" }
        default: false
        }
    }

    public var isNetworkError: Bool {
        switch self {
        case let .client(error):
            [.notConnectedToInternet, .networkConnectionLost, .timedOut].contains(error.code)
        default:
            false
        }
    }

    public var isRetryable: Bool {
        isNetworkError || self == .http(500) || self == .http(502) || self == .http(503)
    }
}
