import Foundation

/// Aggregate totals used by the month-total header and the Insights dashboard.
struct SubscriptionTotals {
    let monthlyTotal: Decimal
    let yearlyTotal: Decimal
    let totalsByPeriod: [BillingPeriod: Decimal]
}

/// Auto-converts every subscription's period to a monthly/yearly equivalent and sums them —
/// the spec's "weekly/yearly -> monthly equivalent" hook.
struct CalculateTotalsUseCase {
    func execute(subscriptions: [Subscription]) -> SubscriptionTotals {
        var monthlyTotal: Decimal = 0
        var yearlyTotal: Decimal = 0
        var totalsByPeriod: [BillingPeriod: Decimal] = [:]

        for subscription in subscriptions {
            monthlyTotal += subscription.monthlyEquivalent
            yearlyTotal += subscription.yearlyEquivalent
            totalsByPeriod[subscription.period, default: 0] += subscription.monthlyEquivalent
        }

        return SubscriptionTotals(monthlyTotal: monthlyTotal, yearlyTotal: yearlyTotal, totalsByPeriod: totalsByPeriod)
    }
}
