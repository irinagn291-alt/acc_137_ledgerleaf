import Foundation

/// Validates and persists edits to an existing subscription, refreshing its reminder.
@MainActor
struct UpdateSubscriptionUseCase {
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
        try repository.update(sanitized)

        await reminderScheduler.cancelReminder(for: sanitized.id)
        if sanitized.isReminderEnabled {
            await reminderScheduler.scheduleReminder(for: sanitized)
        }
    }
}
