import Foundation

/// Drives the main "Leaf" tab: the subscription list, its month-total header,
/// the upcoming-charges timeline, and the per-row "cancel and save" hook.
@MainActor
@Observable
final class LeafListViewModel {
    private(set) var subscriptions: [Subscription] = []
    private(set) var totals = SubscriptionTotals(monthlyTotal: 0, yearlyTotal: 0, totalsByPeriod: [:])
    private(set) var upcomingCharges: [Subscription] = []
    var errorMessage: String?
    var searchText: String = ""

    private let fetchSubscriptions: FetchSubscriptionsUseCase
    private let deleteSubscription: DeleteSubscriptionUseCase
    private let calculateTotals: CalculateTotalsUseCase
    private let upcomingChargesUseCase: UpcomingChargesUseCase
    private let calculateCancelSavings: CalculateCancelSavingsUseCase
    private let seedSampleData: SeedSampleDataUseCase

    init(
        fetchSubscriptions: FetchSubscriptionsUseCase,
        deleteSubscription: DeleteSubscriptionUseCase,
        calculateTotals: CalculateTotalsUseCase,
        upcomingCharges: UpcomingChargesUseCase,
        calculateCancelSavings: CalculateCancelSavingsUseCase,
        seedSampleData: SeedSampleDataUseCase
    ) {
        self.fetchSubscriptions = fetchSubscriptions
        self.deleteSubscription = deleteSubscription
        self.calculateTotals = calculateTotals
        self.upcomingChargesUseCase = upcomingCharges
        self.calculateCancelSavings = calculateCancelSavings
        self.seedSampleData = seedSampleData
    }

    var filteredSubscriptions: [Subscription] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return subscriptions }
        return subscriptions.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var isEmpty: Bool { subscriptions.isEmpty }

    func load() {
        do {
            subscriptions = try fetchSubscriptions.execute()
            totals = calculateTotals.execute(subscriptions: subscriptions)
            upcomingCharges = upcomingChargesUseCase.execute(subscriptions: subscriptions)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ subscription: Subscription) {
        do {
            try deleteSubscription.execute(id: subscription.id)
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancelSavings(for subscription: Subscription) -> Decimal {
        calculateCancelSavings.execute(for: subscription)
    }

    /// Populates the tracker with realistic demo subscriptions so an empty list can
    /// show its month-total, upcoming charges, and analytics right away.
    func loadSampleData() {
        do {
            try seedSampleData.execute()
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// 0...1 weight of how "heavy" a subscription is relative to the priciest one currently tracked —
    /// used to tint the row's leaf marker between the brand's secondary and primary colors.
    func weight(for subscription: Subscription) -> Double {
        let maxMonthly = subscriptions.map(\.monthlyEquivalent).max() ?? 0
        guard maxMonthly > 0 else { return 0 }
        return (NSDecimalNumber(decimal: subscription.monthlyEquivalent).doubleValue) / (NSDecimalNumber(decimal: maxMonthly).doubleValue)
    }
}
