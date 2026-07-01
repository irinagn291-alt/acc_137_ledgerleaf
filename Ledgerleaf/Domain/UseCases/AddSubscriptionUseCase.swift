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

/// Validates and persists a new subscription, then schedules its reminder if enabled.
@MainActor
struct AddSubscriptionUseCase {
    private let repository: SubscriptionRepository
    private let reminderScheduler: ReminderScheduling

    init(repository: SubscriptionRepository, reminderScheduler: ReminderScheduling) {
        self.repository = repository
        self.reminderScheduler = reminderScheduler
    }

    func execute(_ subscription: Subscription) async throws {
        let trimmedName = subscription.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { throw SubscriptionValidationError.emptyName }
        guard subscription.amount > 0 else { throw SubscriptionValidationError.nonPositiveAmount }

        var sanitized = subscription
        sanitized.name = trimmedName
        try repository.add(sanitized)

        if sanitized.isReminderEnabled {
            await reminderScheduler.scheduleReminder(for: sanitized)
        }
    }
}
