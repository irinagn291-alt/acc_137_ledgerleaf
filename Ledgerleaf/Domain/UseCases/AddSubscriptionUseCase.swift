import Foundation

enum SubscriptionValidationError: Error, LocalizedError {
    case emptyName
    case nonPositiveAmount

    var errorDescription: String? {
        switch self {
        case .emptyName: return "Enter a subscription name."
        case .nonPositiveAmount: return "Amount must be greater than zero."
        }
    }
}

/// Validates and persists a new subscription.
@MainActor
struct AddSubscriptionUseCase {
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
        try repository.add(sanitized)
    }
}
