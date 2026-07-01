import Foundation

/// Abstracts persistence for `Subscription` so use cases never depend on SwiftData directly.
@MainActor
protocol SubscriptionRepository {
    func fetchAll() throws -> [Subscription]
    func add(_ subscription: Subscription) throws
    func update(_ subscription: Subscription) throws
    func delete(id: UUID) throws
}
