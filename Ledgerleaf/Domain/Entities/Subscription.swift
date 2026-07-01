import Foundation

/// A single recurring payment the user tracks manually.
/// No card or bank linking is ever associated with this entity — amounts are
/// entered by hand, per the product's "no transactional chaos" differentiator.
struct Subscription: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var amount: Decimal
    var currencyCode: String
    var period: BillingPeriod
    var nextChargeDate: Date
    var isReminderEnabled: Bool
    var notes: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        amount: Decimal,
        currencyCode: String = "EUR",
        period: BillingPeriod,
        nextChargeDate: Date,
        isReminderEnabled: Bool = true,
        notes: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.currencyCode = currencyCode
        self.period = period
        self.nextChargeDate = nextChargeDate
        self.isReminderEnabled = isReminderEnabled
        self.notes = notes
        self.createdAt = createdAt
    }

    /// Cost normalized to a monthly cadence, regardless of the original period.
    var monthlyEquivalent: Decimal {
        amount * Decimal(period.occurrencesPerMonth)
    }

    /// Cost normalized to a yearly cadence — used for the "cancel and save" hook.
    var yearlyEquivalent: Decimal {
        amount * Decimal(period.occurrencesPerYear)
    }
}

extension Subscription {
    /// Days from now until the next charge. Negative values mean the charge date is overdue.
    func daysUntilNextCharge(referenceDate: Date = .now) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: referenceDate)
        let end = calendar.startOfDay(for: nextChargeDate)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }
}
