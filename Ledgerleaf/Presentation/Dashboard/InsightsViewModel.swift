import Foundation

/// A single bar in the "totals by period" chart.
struct PeriodBreakdown: Identifiable {
    let period: BillingPeriod
    var id: String { period.id }
    let monthlyEquivalentTotal: Decimal
}

/// A single bar in the "top subscriptions" chart.
struct TopSubscriptionEntry: Identifiable {
    let id: UUID
    let name: String
    let monthlyEquivalentAmount: Decimal
}

/// Drives the Insights tab: month/year totals, spend trend, per-period and
/// per-subscription analytics, currency distribution, and the 12-month forecast.
@MainActor
@Observable
final class InsightsViewModel {
    private(set) var totals = SubscriptionTotals(monthlyTotal: 0, yearlyTotal: 0, totalsByPeriod: [:])
    private(set) var spendTrend: [SpendTrendPoint] = []
    private(set) var periodBreakdown: [PeriodBreakdown] = []
    private(set) var topSubscriptions: [TopSubscriptionEntry] = []
    private(set) var currencyBreakdown: [CurrencyBreakdownEntry] = []
    private(set) var forecast: [MonthlyForecastPoint] = []
    private(set) var subscriptionCount = 0
    var errorMessage: String?

    private let fetchSubscriptions: FetchSubscriptionsUseCase
    private let calculateTotals: CalculateTotalsUseCase
    private let calculateSpendTrend: CalculateSpendTrendUseCase
    private let calculateCurrencyBreakdown: CalculateCurrencyBreakdownUseCase
    private let forecastNextYear: ForecastNextYearUseCase

    init(
        fetchSubscriptions: FetchSubscriptionsUseCase,
        calculateTotals: CalculateTotalsUseCase,
        calculateSpendTrend: CalculateSpendTrendUseCase,
        calculateCurrencyBreakdown: CalculateCurrencyBreakdownUseCase,
        forecastNextYear: ForecastNextYearUseCase
    ) {
        self.fetchSubscriptions = fetchSubscriptions
        self.calculateTotals = calculateTotals
        self.calculateSpendTrend = calculateSpendTrend
        self.calculateCurrencyBreakdown = calculateCurrencyBreakdown
        self.forecastNextYear = forecastNextYear
    }

    func load() {
        do {
            let subscriptions = try fetchSubscriptions.execute()
            subscriptionCount = subscriptions.count
            totals = calculateTotals.execute(subscriptions: subscriptions)
            spendTrend = calculateSpendTrend.execute(subscriptions: subscriptions)
            currencyBreakdown = calculateCurrencyBreakdown.execute(subscriptions: subscriptions)

            periodBreakdown = BillingPeriod.allCases.map { period in
                PeriodBreakdown(period: period, monthlyEquivalentTotal: totals.totalsByPeriod[period] ?? 0)
            }

            topSubscriptions = subscriptions
                .sorted { $0.monthlyEquivalent > $1.monthlyEquivalent }
                .prefix(6)
                .map { TopSubscriptionEntry(id: $0.id, name: $0.name, monthlyEquivalentAmount: $0.monthlyEquivalent) }

            forecast = forecastNextYear.execute(subscriptions: subscriptions)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
