import Foundation
import UserNotifications

/// Schedules local "charge is coming" reminders via `UNUserNotificationCenter` only.
/// No push SDK, no remote-triggered content — every notification is generated and
/// scheduled entirely on-device from the subscription's own next-charge date.
@MainActor
final class UNNotificationReminderScheduler: ReminderScheduling {
    private let center = UNUserNotificationCenter.current()
    private let daysBeforeCharge = 2

    func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return true
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        case .denied, .ephemeral:
            return false
        @unknown default:
            return false
        }
    }

    func scheduleReminder(for subscription: Subscription) async {
        guard subscription.isReminderEnabled else { return }

        let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBeforeCharge, to: subscription.nextChargeDate)
        guard let triggerDate, triggerDate > .now else { return }

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming charge"
        content.body = Self.reminderBody(name: subscription.name, amount: subscription.amount, currencyCode: subscription.currencyCode, daysBeforeCharge: daysBeforeCharge)
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        dateComponents.hour = 10
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: Self.identifier(for: subscription.id), content: content, trigger: trigger)
        try? await center.add(request)
    }

    func cancelReminder(for subscriptionID: UUID) async {
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifier(for: subscriptionID)])
    }

    func cancelAllReminders() async {
        center.removeAllPendingNotificationRequests()
    }

    private static func identifier(for subscriptionID: UUID) -> String {
        "reminder.\(subscriptionID.uuidString)"
    }

    /// Mirrors the spec's notification copy: "Netflix charges €11.99 in 2 days. Still need it?"
    static func reminderBody(name: String, amount: Decimal, currencyCode: String, daysBeforeCharge: Int) -> String {
        let formattedAmount = CurrencyFormatter.format(amount, currencyCode: currencyCode)
        return "\(name) charges \(formattedAmount) in \(daysBeforeCharge) days. Still need it?"
    }
}
