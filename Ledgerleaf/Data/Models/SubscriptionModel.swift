import Foundation
import SwiftData

/// SwiftData persistence model mirroring the `Subscription` domain entity.
/// Mapping to/from `Subscription` happens in `SwiftDataSubscriptionRepository`.
@Model
final class SubscriptionModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Decimal
    var currencyCode: String
    var periodRawValue: String
    var nextChargeDate: Date
    var notes: String
    var createdAt: Date

    init(
        id: UUID,
        name: String,
        amount: Decimal,
        currencyCode: String,
        periodRawValue: String,
        nextChargeDate: Date,
        notes: String,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.currencyCode = currencyCode
        self.periodRawValue = periodRawValue
        self.nextChargeDate = nextChargeDate
        self.notes = notes
        self.createdAt = createdAt
    }
}

extension SubscriptionModel {
    convenience init(domain: Subscription) {
        self.init(
            id: domain.id,
            name: domain.name,
            amount: domain.amount,
            currencyCode: domain.currencyCode,
            periodRawValue: domain.period.rawValue,
            nextChargeDate: domain.nextChargeDate,
            notes: domain.notes,
            createdAt: domain.createdAt
        )
    }

    func apply(_ domain: Subscription) {
        name = domain.name
        amount = domain.amount
        currencyCode = domain.currencyCode
        periodRawValue = domain.period.rawValue
        nextChargeDate = domain.nextChargeDate
        notes = domain.notes
    }

    func toDomain() -> Subscription {
        Subscription(
            id: id,
            name: name,
            amount: amount,
            currencyCode: currencyCode,
            period: BillingPeriod(rawValue: periodRawValue) ?? .monthly,
            nextChargeDate: nextChargeDate,
            notes: notes,
            createdAt: createdAt
        )
    }
}
