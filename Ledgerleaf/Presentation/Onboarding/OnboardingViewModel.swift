import Foundation

/// Drives the spec's 3-screen, value-first onboarding: tease the total, add a first
/// subscription, then reveal the real load.
@MainActor
@Observable
final class OnboardingViewModel {
    var currentStep = 0
    var draftName = ""
    var draftAmountText = ""
    var draftPeriod: BillingPeriod = .monthly
    var draftNextChargeDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
    var errorMessage: String?
    private(set) var isSaving = false
    private(set) var subscriptions: [Subscription] = []

    let stepCount = 3

    private let fetchSubscriptions: FetchSubscriptionsUseCase
    private let addSubscription: AddSubscriptionUseCase

    init(fetchSubscriptions: FetchSubscriptionsUseCase, addSubscription: AddSubscriptionUseCase) {
        self.fetchSubscriptions = fetchSubscriptions
        self.addSubscription = addSubscription
    }

    var monthlyTotal: Decimal {
        subscriptions.reduce(Decimal(0)) { $0 + $1.monthlyEquivalent }
    }

    func refreshSubscriptions() {
        subscriptions = (try? fetchSubscriptions.execute()) ?? []
    }

    func goToNextStep() {
        guard currentStep < stepCount - 1 else { return }
        currentStep += 1
    }

    func addDraftSubscription() async -> Bool {
        errorMessage = nil
        let normalizedAmount = draftAmountText.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)
        guard let amount = Decimal(string: normalizedAmount), amount > 0 else {
            errorMessage = "Enter a valid amount."
            return false
        }
        guard !draftName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Enter a subscription name."
            return false
        }

        isSaving = true
        defer { isSaving = false }

        let subscription = Subscription(
            name: draftName,
            amount: amount,
            period: draftPeriod,
            nextChargeDate: draftNextChargeDate
        )

        do {
            try addSubscription.execute(subscription)
            HapticsService.totalIncremented()
            refreshSubscriptions()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
