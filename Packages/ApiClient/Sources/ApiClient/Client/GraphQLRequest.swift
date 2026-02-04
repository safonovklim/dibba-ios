import Foundation

// MARK: - GraphQL Request

public struct GraphQLRequest<Variables: Encodable & Sendable>: Encodable, Sendable {
    public let query: String
    public let variables: Variables?
    public let operationName: String?

    public init(
        query: String,
        variables: Variables? = nil,
        operationName: String? = nil
    ) {
        self.query = query
        self.variables = variables
        self.operationName = operationName
    }
}

// MARK: - Empty Variables

public struct EmptyVariables: Encodable, Sendable {
    public init() {}
}

// MARK: - GraphQL Response

public struct GraphQLResponse<T: Decodable>: Decodable {
    public let data: T?
    public let errors: [GraphQLError]?

    public init(data: T?, errors: [GraphQLError]?) {
        self.data = data
        self.errors = errors
    }
}
