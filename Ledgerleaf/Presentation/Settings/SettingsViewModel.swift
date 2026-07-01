import Foundation

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

/// Drives Settings: appearance, CSV export, reminder permission, and data reset.
@MainActor
@Observable
final class SettingsViewModel {
    var errorMessage: String?
    private(set) var exportURL: URL?
    private(set) var notificationsAuthorized = false
    private(set) var subscriptionCount = 0

    private let fetchSubscriptions: FetchSubscriptionsUseCase
    private let exportCSV: ExportSubscriptionsCSVUseCase
    private let reminderScheduler: ReminderScheduling
    private let seedSampleData: SeedSampleDataUseCase

    init(
        fetchSubscriptions: FetchSubscriptionsUseCase,
        exportCSV: ExportSubscriptionsCSVUseCase,
        reminderScheduler: ReminderScheduling,
        seedSampleData: SeedSampleDataUseCase
    ) {
        self.fetchSubscriptions = fetchSubscriptions
        self.exportCSV = exportCSV
        self.reminderScheduler = reminderScheduler
        self.seedSampleData = seedSampleData
    }

    func load() {
        subscriptionCount = (try? fetchSubscriptions.execute().count) ?? 0
    }

    /// Populates the tracker with realistic demo subscriptions — useful to preview
    /// Insights/Statistics fully populated without entering data by hand.
    func loadSampleData() {
        do {
            try seedSampleData.execute()
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func prepareExport() {
        do {
            let subscriptions = try fetchSubscriptions.execute()
            exportURL = try exportCSV.execute(subscriptions: subscriptions)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func enableReminders() async -> Bool {
        let granted = await reminderScheduler.requestAuthorizationIfNeeded()
        notificationsAuthorized = granted
        if !granted {
            errorMessage = "Allow notifications in iOS Settings to receive reminders."
        }
        return granted
    }

    func disableReminders() async {
        await reminderScheduler.cancelAllReminders()
        notificationsAuthorized = false
    }
}
