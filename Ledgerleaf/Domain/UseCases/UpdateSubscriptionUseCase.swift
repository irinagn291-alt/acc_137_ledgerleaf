import Foundation

/// Validates and persists edits to an existing subscription.
@MainActor
struct UpdateSubscriptionUseCase {
    private let repository: SubscriptionRepository

    init(repository: SubscriptionRepository) {
        self.repository = repository
    }

    func execute(_ subscription: Subscription) throws {
        let trimmedName = subscription.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { throw SubscriptionValidationError.emptyName }
        guard subscription.amount > 0 else { throw SubscriptionValidationError.nonPositiveAmount }

        var sanitized = subscription
        sanitized.name = trimmedName
        try repository.update(sanitized)
    }
}
