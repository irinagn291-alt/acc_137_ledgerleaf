import Foundation

/// Removes a subscription and cancels any pending reminder for it.
@MainActor
struct DeleteSubscriptionUseCase {
    private let repository: SubscriptionRepository
    private let reminderScheduler: ReminderScheduling

    init(repository: SubscriptionRepository, reminderScheduler: ReminderScheduling) {
        self.repository = repository
        self.reminderScheduler = reminderScheduler
    }

    func execute(id: UUID) async throws {
        try repository.delete(id: id)
        await reminderScheduler.cancelReminder(for: id)
    }
}
