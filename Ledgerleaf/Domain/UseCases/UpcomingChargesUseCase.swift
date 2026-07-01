import Foundation

/// Powers the "Leaf" timeline of nearest upcoming charges on the main screen.
struct UpcomingChargesUseCase {
    func execute(subscriptions: [Subscription], limit: Int = 5, referenceDate: Date = .now) -> [Subscription] {
        subscriptions
            .sorted { $0.nextChargeDate < $1.nextChargeDate }
            .filter { $0.daysUntilNextCharge(referenceDate: referenceDate) >= -1 }
            .prefix(limit)
            .map { $0 }
    }
}
