import Foundation
import Dependencies
import Sharing
import ApiClient

// MARK: - Target Service Protocol

public protocol TargetServicing: Sendable {
    /// Get all targets (savings goals)
    func getTargets(force: Bool) async throws -> [Target]

    /// Create a new target
    func createTarget(_ input: CreateTargetInput) async throws -> Target

    /// Update an existing target
    func updateTarget(id: String, input: UpdateTargetInput) async throws -> Target

    /// Get cached targets
    var cachedTargets: [Target] { get async }

    /// Clear cached data
    func clearCache() async
}

// MARK: - Target Service Implementation

public actor TargetService: TargetServicing {
    @Dependency(\.apiClient) private var client

    // In-memory cache for targets
    @Shared(.inMemory("cachedTargets")) private var _cachedTargets: [Target]?

    // Task deduplication
    private var getTargetsTask: Task<[Target], any Error>?

    public init() {}

    // MARK: - Public Methods

    public var cachedTargets: [Target] {
        _cachedTargets ?? []
    }

    @discardableResult
    public func getTargets(force: Bool = false) async throws -> [Target] {
        // Return in-flight request if exists
        if let getTargetsTask {
            return try await getTargetsTask.value
        }

        // Return cache if not forcing refresh
        if let cached = _cachedTargets, !cached.isEmpty, !force {
            return cached
        }

        let task = Task<[Target], any Error> {
            let dtos = try await client.listTargets()
            return dtos.map { Target(from: $0) }
        }

        getTargetsTask = task
        defer { getTargetsTask = nil }

        let targets = try await task.value
        $_cachedTargets.withLock { $0 = targets }
        return targets
    }

    public func createTarget(_ input: CreateTargetInput) async throws -> Target {
        let dto = try await client.createTarget(input: input)
        let target = Target(from: dto)

        // Add to cache
        $_cachedTargets.withLock { cached in
            var targets = cached ?? []
            targets.insert(target, at: 0)
            cached = targets
        }

        return target
    }

    public func updateTarget(id: String, input: UpdateTargetInput) async throws -> Target {
        let dto = try await client.updateTarget(id: id, input: input)
        let target = Target(from: dto)

        // Update cache
        $_cachedTargets.withLock { cached in
            guard var targets = cached else { return }

            // If archived, remove from list
            if input.archived == true {
                targets = targets.filter { $0.id != id }
            } else if let index = targets.firstIndex(where: { $0.id == id }) {
                targets[index] = target
            }

            cached = targets
        }

        return target
    }

    public func clearCache() {
        $_cachedTargets.withLock { $0 = nil }
        getTargetsTask?.cancel()
        getTargetsTask = nil
    }
}

// MARK: - Target Conversion

extension Target {
    init(from dto: TargetDTO) {
        let strategy: TargetStrategy
        if let strategyString = dto.strategy {
            strategy = TargetStrategy(rawValue: strategyString) ?? .open
        } else {
            strategy = .open
        }

        self.init(
            id: dto.id,
            emoji: dto.emoji ?? "🎯",
            name: dto.name,
            strategy: strategy,
            currency: dto.currency ?? "USD",
            amountSaved: dto.amountSaved ?? 0,
            amountTarget: dto.amountTarget ?? 0,
            expectedStartAt: dto.expectedStartAt ?? Date(),
            expectedEndAt: dto.expectedEndAt ?? Calendar.current.date(byAdding: .month, value: 6, to: Date())!,
            remindWeekly: dto.remindWeekly ?? false,
            remindMonthly: dto.remindMonthly ?? true,
            completed: dto.completed ?? false,
            archived: dto.archived ?? false,
            createdAt: dto.createdAt ?? Date(),
            updatedAt: dto.updatedAt ?? Date()
        )
    }
}

// MARK: - Dependency Registration

extension TargetService: DependencyKey {
    public static let liveValue: any TargetServicing = TargetService()
    public static let testValue: any TargetServicing = TargetService()
}

public extension DependencyValues {
    var targetService: any TargetServicing {
        get { self[TargetService.self] }
        set { self[TargetService.self] = newValue }
    }
}
