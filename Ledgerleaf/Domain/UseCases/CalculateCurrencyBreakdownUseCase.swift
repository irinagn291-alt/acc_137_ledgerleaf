import Foundation

/// A single currency's share of the tracked subscriptions.
struct CurrencyBreakdownEntry: Identifiable {
    var id: String { currencyCode }
    let currencyCode: String
    let monthlyTotal: Decimal
    let count: Int
}

/// Groups subscriptions by their billing currency. Ledgerleaf never converts between
/// currencies, so each currency's load is reported on its own rather than summed together.
struct CalculateCurrencyBreakdownUseCase {
    func execute(subscriptions: [Subscription]) -> [CurrencyBreakdownEntry] {
        Dictionary(grouping: subscriptions, by: \.currencyCode)
            .map { currencyCode, subscriptions in
                CurrencyBreakdownEntry(
                    currencyCode: currencyCode,
                    monthlyTotal: subscriptions.reduce(Decimal(0)) { $0 + $1.monthlyEquivalent },
                    count: subscriptions.count
                )
            }
            .sorted { $0.monthlyTotal > $1.monthlyTotal }
    }
}
