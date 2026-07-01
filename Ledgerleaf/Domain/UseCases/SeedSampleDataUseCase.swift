import Foundation

/// Populates the tracker with a realistic set of demo subscriptions spread across
/// several months of history, so new users (and previews/screenshots) can see the
/// month-total header, upcoming charges, period/currency breakdowns, and the spend
/// trend fully populated on first launch.
///
/// Adds directly through the repository, bypassing the free-tier cap that applies
/// to subscriptions entered by hand.
@MainActor
struct SeedSampleDataUseCase {
    private let repository: SubscriptionRepository

    init(repository: SubscriptionRepository) {
        self.repository = repository
    }

    func execute(referenceDate: Date = .now) throws {
        for sample in Self.samples(referenceDate: referenceDate) {
            try repository.add(sample)
        }
    }

    private static func samples(referenceDate: Date) -> [Subscription] {
        let calendar = Calendar.current
        func daysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: referenceDate) ?? referenceDate
        }
        func daysFromNow(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: days, to: referenceDate) ?? referenceDate
        }

        return [
            Subscription(
                name: "Netflix", amount: 17.99, currencyCode: "EUR", period: .monthly,
                nextChargeDate: daysFromNow(6), notes: "Premium plan", createdAt: daysAgo(240)
            ),
            Subscription(
                name: "iCloud+ 200GB", amount: 2.99, currencyCode: "EUR", period: .monthly,
                nextChargeDate: daysFromNow(11), createdAt: daysAgo(235)
            ),
            Subscription(
                name: "Spotify", amount: 10.99, currencyCode: "EUR", period: .monthly,
                nextChargeDate: daysFromNow(3), notes: "Family plan", createdAt: daysAgo(210)
            ),
            Subscription(
                name: "Amazon Prime", amount: 89, currencyCode: "USD", period: .yearly,
                nextChargeDate: daysFromNow(58), createdAt: daysAgo(180)
            ),
            Subscription(
                name: "Adobe Creative Cloud", amount: 59.99, currencyCode: "EUR", period: .monthly,
                nextChargeDate: daysFromNow(18), notes: "All apps", createdAt: daysAgo(150)
            ),
            Subscription(
                name: "Gym Membership", amount: 44.90, currencyCode: "EUR", period: .monthly,
                nextChargeDate: daysFromNow(2), createdAt: daysAgo(120)
            ),
            Subscription(
                name: "YouTube Premium", amount: 13.99, currencyCode: "EUR", period: .monthly,
                nextChargeDate: daysFromNow(21), createdAt: daysAgo(90)
            ),
            Subscription(
                name: "Disney+", amount: 11.99, currencyCode: "EUR", period: .monthly,
                nextChargeDate: daysFromNow(27), createdAt: daysAgo(60)
            ),
            Subscription(
                name: "ChatGPT Plus", amount: 20, currencyCode: "USD", period: .monthly,
                nextChargeDate: daysFromNow(9), createdAt: daysAgo(30)
            ),
            Subscription(
                name: "Notion Plus", amount: 9.50, currencyCode: "EUR", period: .monthly,
                nextChargeDate: daysFromNow(14), createdAt: daysAgo(10)
            )
        ]
    }
}
