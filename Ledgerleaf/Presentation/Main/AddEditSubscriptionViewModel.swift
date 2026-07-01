import Foundation

/// Backs the bottom-sheet form used to both add a new subscription and edit an existing one.
@MainActor
@Observable
final class AddEditSubscriptionViewModel {
    var name: String
    var amountText: String
    var period: BillingPeriod
    var nextChargeDate: Date
    var isReminderEnabled: Bool
    var notes: String
    var errorMessage: String?
    private(set) var isSaving = false

    let isEditing: Bool
    private let editingID: UUID?
    private let createdAt: Date
    private let addSubscription: AddSubscriptionUseCase
    private let updateSubscription: UpdateSubscriptionUseCase

    init(editingSubscription: Subscription?, addSubscription: AddSubscriptionUseCase, updateSubscription: UpdateSubscriptionUseCase) {
        self.isEditing = editingSubscription != nil
        self.editingID = editingSubscription?.id
        self.createdAt = editingSubscription?.createdAt ?? .now
        self.name = editingSubscription?.name ?? ""
        self.amountText = editingSubscription.map { Self.format($0.amount) } ?? ""
        self.period = editingSubscription?.period ?? .monthly
        self.nextChargeDate = editingSubscription?.nextChargeDate ?? Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
        self.isReminderEnabled = editingSubscription?.isReminderEnabled ?? true
        self.notes = editingSubscription?.notes ?? ""
        self.addSubscription = addSubscription
        self.updateSubscription = updateSubscription
    }

    /// Live preview for the "cancel and save" hook while the user is still filling the form.
    var yearlySavingsPreview: Decimal {
        guard let amount = parsedAmount() else { return 0 }
        return amount * Decimal(period.occurrencesPerYear)
    }

    func save() async -> Bool {
        errorMessage = nil
        guard let amount = parsedAmount() else {
            errorMessage = "Enter a valid amount."
            return false
        }
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Enter a subscription name."
            return false
        }

        isSaving = true
        defer { isSaving = false }

        let subscription = Subscription(
            id: editingID ?? UUID(),
            name: name,
            amount: amount,
            period: period,
            nextChargeDate: nextChargeDate,
            isReminderEnabled: isReminderEnabled,
            notes: notes,
            createdAt: createdAt
        )

        do {
            if isEditing {
                try await updateSubscription.execute(subscription)
            } else {
                try await addSubscription.execute(subscription)
                HapticsService.totalIncremented()
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func parsedAmount() -> Decimal? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)
        guard let value = Decimal(string: normalized), value > 0 else { return nil }
        return value
    }

    private static func format(_ amount: Decimal) -> String {
        NSDecimalNumber(decimal: amount).stringValue
    }
}
