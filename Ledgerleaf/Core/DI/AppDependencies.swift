import Foundation
import SwiftData

/// Lightweight DI container. Built once in `RootView` from the live `ModelContext`
/// and handed down to feature views, which use its factory methods to build their
/// own `@Observable` view models — no singletons, no service-locator lookups.
@MainActor
final class AppDependencies {
    let subscriptionRepository: SubscriptionRepository
    let reminderScheduler: ReminderScheduling
    private let csvExporter: SubscriptionCSVExporting

    init(modelContext: ModelContext) {
        self.subscriptionRepository = SwiftDataSubscriptionRepository(modelContext: modelContext)
        self.reminderScheduler = UNNotificationReminderScheduler()
        self.csvExporter = SubscriptionCSVExporter()
    }

    func makeLeafListViewModel() -> LeafListViewModel {
        LeafListViewModel(
            fetchSubscriptions: FetchSubscriptionsUseCase(repository: subscriptionRepository),
            deleteSubscription: DeleteSubscriptionUseCase(repository: subscriptionRepository, reminderScheduler: reminderScheduler),
            calculateTotals: CalculateTotalsUseCase(),
            upcomingCharges: UpcomingChargesUseCase(),
            calculateCancelSavings: CalculateCancelSavingsUseCase(),
            seedSampleData: SeedSampleDataUseCase(repository: subscriptionRepository)
        )
    }

    func makeAddEditSubscriptionViewModel(editing subscription: Subscription?) -> AddEditSubscriptionViewModel {
        AddEditSubscriptionViewModel(
            editingSubscription: subscription,
            addSubscription: AddSubscriptionUseCase(repository: subscriptionRepository, reminderScheduler: reminderScheduler),
            updateSubscription: UpdateSubscriptionUseCase(repository: subscriptionRepository, reminderScheduler: reminderScheduler)
        )
    }

    func makeInsightsViewModel() -> InsightsViewModel {
        InsightsViewModel(
            fetchSubscriptions: FetchSubscriptionsUseCase(repository: subscriptionRepository),
            calculateTotals: CalculateTotalsUseCase(),
            calculateSpendTrend: CalculateSpendTrendUseCase(),
            calculateCurrencyBreakdown: CalculateCurrencyBreakdownUseCase(),
            forecastNextYear: ForecastNextYearUseCase()
        )
    }

    func makeStatisticsViewModel() -> StatisticsViewModel {
        StatisticsViewModel(
            fetchSubscriptions: FetchSubscriptionsUseCase(repository: subscriptionRepository),
            calculateTotals: CalculateTotalsUseCase(),
            calculateCurrencyBreakdown: CalculateCurrencyBreakdownUseCase()
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            fetchSubscriptions: FetchSubscriptionsUseCase(repository: subscriptionRepository),
            exportCSV: ExportSubscriptionsCSVUseCase(exporter: csvExporter),
            reminderScheduler: reminderScheduler,
            seedSampleData: SeedSampleDataUseCase(repository: subscriptionRepository)
        )
    }

    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(
            fetchSubscriptions: FetchSubscriptionsUseCase(repository: subscriptionRepository),
            addSubscription: AddSubscriptionUseCase(repository: subscriptionRepository, reminderScheduler: reminderScheduler),
            reminderScheduler: reminderScheduler
        )
    }
}
