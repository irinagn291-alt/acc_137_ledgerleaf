import Foundation

/// A single subscription's ranked share of the total monthly load.
struct RankedSubscriptionEntry: Identifiable {
    var id: UUID { subscription.id }
    let subscription: Subscription
    let shareOfTotal: Double
}

/// Drives the full Statistics screen reached from Insights: headline numbers,
/// ranked spend breakdown, currency distribution, and the near-term charge load.
@MainActor
@Observable
final class StatisticsViewModel {
    private(set) var subscriptionCount = 0
    private(set) var averageMonthlyCost: Decimal = 0
    private(set) var mostExpensive: Subscription?
    private(set) var cheapest: Subscription?
    private(set) var rankedByShare: [RankedSubscriptionEntry] = []
    private(set) var currencyBreakdown: [CurrencyBreakdownEntry] = []
    private(set) var next30DaysCount = 0
    var errorMessage: String?

    private let fetchSubscriptions: FetchSubscriptionsUseCase
    private let calculateTotals: CalculateTotalsUseCase
    private let calculateCurrencyBreakdown: CalculateCurrencyBreakdownUseCase

    init(
        fetchSubscriptions: FetchSubscriptionsUseCase,
        calculateTotals: CalculateTotalsUseCase,
        calculateCurrencyBreakdown: CalculateCurrencyBreakdownUseCase
    ) {
        self.fetchSubscriptions = fetchSubscriptions
        self.calculateTotals = calculateTotals
        self.calculateCurrencyBreakdown = calculateCurrencyBreakdown
    }

    func load() {
        do {
            let subscriptions = try fetchSubscriptions.execute()
            subscriptionCount = subscriptions.count

            let totals = calculateTotals.execute(subscriptions: subscriptions)
            averageMonthlyCost = subscriptionCount > 0 ? totals.monthlyTotal / Decimal(subscriptionCount) : 0
            mostExpensive = subscriptions.max { $0.monthlyEquivalent < $1.monthlyEquivalent }
            cheapest = subscriptions.min { $0.monthlyEquivalent < $1.monthlyEquivalent }

            let maxMonthly = NSDecimalNumber(decimal: totals.monthlyTotal).doubleValue
            rankedByShare = subscriptions
                .sorted { $0.monthlyEquivalent > $1.monthlyEquivalent }
                .map { subscription in
                    let share = maxMonthly > 0
                        ? NSDecimalNumber(decimal: subscription.monthlyEquivalent).doubleValue / maxMonthly
                        : 0
                    return RankedSubscriptionEntry(subscription: subscription, shareOfTotal: share)
                }

            currencyBreakdown = calculateCurrencyBreakdown.execute(subscriptions: subscriptions)
            next30DaysCount = subscriptions.filter { (0...30).contains($0.daysUntilNextCharge()) }.count
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
