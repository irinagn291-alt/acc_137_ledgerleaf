import Foundation

/// A single month's reconstructed monthly-equivalent load, for the Insights "spend trend" chart.
struct SpendTrendPoint: Identifiable {
    let id = UUID()
    let monthDate: Date
    let total: Decimal
}

/// Reconstructs the monthly load over the past N months by replaying which subscriptions
/// already existed (by `createdAt`) at the end of each month. This is an honest
/// approximation of growth over time, not a ledger of past charges — Ledgerleaf never
/// stores historical amounts, only the current state of each subscription.
struct CalculateSpendTrendUseCase {
    func execute(subscriptions: [Subscription], monthsBack: Int = 6, referenceDate: Date = .now) -> [SpendTrendPoint] {
        let calendar = Calendar.current

        return (0..<monthsBack).reversed().compactMap { offset -> SpendTrendPoint? in
            guard let monthDate = calendar.date(byAdding: .month, value: -offset, to: referenceDate),
                  let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else {
                return nil
            }

            let total = subscriptions
                .filter { $0.createdAt < monthInterval.end }
                .reduce(Decimal(0)) { $0 + $1.monthlyEquivalent }

            return SpendTrendPoint(monthDate: monthInterval.start, total: total)
        }
    }
}
