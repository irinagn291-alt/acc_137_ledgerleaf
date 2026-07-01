import Foundation

/// Powers the "if you cancel X, you save Y/year" hook.
struct CalculateCancelSavingsUseCase {
    func execute(for subscription: Subscription) -> Decimal {
        subscription.yearlyEquivalent
    }
}
