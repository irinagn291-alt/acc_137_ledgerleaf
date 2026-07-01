import Foundation

/// A single month's projected spend in the year forecast, an Insights feature.
struct MonthlyForecastPoint: Identifiable {
    let id = UUID()
    let monthDate: Date
    let projectedTotal: Decimal
}

/// Projects spend for each of the next N months, accounting for which months yearly
/// subscriptions actually charge rather than smearing their cost evenly.
struct ForecastNextYearUseCase {
    func execute(subscriptions: [Subscription], referenceDate: Date = .now, monthsAhead: Int = 12) -> [MonthlyForecastPoint] {
        let calendar = Calendar.current

        return (0..<monthsAhead).compactMap { offset -> MonthlyForecastPoint? in
            guard let monthDate = calendar.date(byAdding: .month, value: offset, to: referenceDate) else { return nil }

            let projectedTotal = subscriptions.reduce(Decimal(0)) { total, subscription in
                total + monthlyCharge(for: subscription, in: monthDate, calendar: calendar)
            }
            return MonthlyForecastPoint(monthDate: monthDate, projectedTotal: projectedTotal)
        }
    }

    private func monthlyCharge(for subscription: Subscription, in monthDate: Date, calendar: Calendar) -> Decimal {
        switch subscription.period {
        case .monthly:
            return subscription.amount
        case .weekly:
            return subscription.amount * Decimal(52.0 / 12.0)
        case .yearly:
            let chargeMonth = calendar.component(.month, from: subscription.nextChargeDate)
            let forecastMonth = calendar.component(.month, from: monthDate)
            return chargeMonth == forecastMonth ? subscription.amount : 0
        }
    }
}
