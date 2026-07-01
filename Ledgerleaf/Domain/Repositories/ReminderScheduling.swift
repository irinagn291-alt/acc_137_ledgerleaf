import Foundation

/// Abstracts local-notification scheduling for charge reminders.
/// Backed exclusively by `UNUserNotificationCenter` — never a push SDK.
@MainActor
protocol ReminderScheduling {
    /// Requests notification permission if not already determined. Returns whether reminders may be scheduled.
    func requestAuthorizationIfNeeded() async -> Bool
    func scheduleReminder(for subscription: Subscription) async
    func cancelReminder(for subscriptionID: UUID) async
    func cancelAllReminders() async
}
