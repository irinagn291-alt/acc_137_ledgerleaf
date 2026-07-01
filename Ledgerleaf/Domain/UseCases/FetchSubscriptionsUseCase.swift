import Foundation

/// Loads all tracked subscriptions, sorted by their nearest upcoming charge.
@MainActor
struct FetchSubscriptionsUseCase {
    private let repository: SubscriptionRepository

    init(repository: SubscriptionRepository) {
        self.repository = repository
    }

    func execute() throws -> [Subscription] {
        try repository.fetchAll().sorted { $0.nextChargeDate < $1.nextChargeDate }
    }
}
