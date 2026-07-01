import SwiftUI

/// Container for the spec's 3-screen, value-first onboarding flow.
struct OnboardingView: View {
    let dependencies: AppDependencies
    let onFinish: () -> Void
    @State private var viewModel: OnboardingViewModel

    init(dependencies: AppDependencies, onFinish: @escaping () -> Void) {
        self.dependencies = dependencies
        self.onFinish = onFinish
        self._viewModel = State(initialValue: dependencies.makeOnboardingViewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(currentStep: viewModel.currentStep, stepCount: viewModel.stepCount)
                .padding(.top, 24)

            TabView(selection: $viewModel.currentStep) {
                MysteryTotalStepView(onContinue: viewModel.goToNextStep)
                    .tag(0)
                AddFirstSubscriptionStepView(viewModel: viewModel)
                    .tag(1)
                LoadRevealStepView(viewModel: viewModel, onFinish: onFinish)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }
        .background(AppColor.background)
        .onAppear { viewModel.refreshSubscriptions() }
    }
}

private struct ProgressDots: View {
    let currentStep: Int
    let stepCount: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<stepCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index == currentStep ? AppColor.primary : AppColor.secondary.opacity(0.3))
                    .frame(width: index == currentStep ? 20 : 8, height: 4)
            }
        }
    }
}

private struct OnboardingScaffold<Visual: View>: View {
    let title: String
    let ctaTitle: String
    let isDisabled: Bool
    let action: () -> Void
    @ViewBuilder let visual: () -> Visual

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            visual()
                .frame(maxHeight: 220)

            Text(title)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.text)
                .padding(.horizontal, 24)

            Spacer()

            Button(action: action) {
                Text(ctaTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColor.primary)
            .disabled(isDisabled)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

private struct MysteryTotalStepView: View {
    let onContinue: () -> Void

    var body: some View {
        OnboardingScaffold(title: "How much goes to subscriptions?", ctaTitle: "Find out", isDisabled: false, action: onContinue) {
            Text("€ ??,??")
                .font(.system(size: 56, weight: .bold, design: .default))
                .monospacedDigit()
                .foregroundStyle(AppColor.text)
                .blur(radius: 10)
        }
    }
}

private struct AddFirstSubscriptionStepView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 12)

            Image(systemName: "doc")
                .font(.system(size: 64))
                .foregroundStyle(AppColor.secondary.opacity(0.4))

            Text("Add your first subscription")
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppColor.text)

            VStack(spacing: 12) {
                TextField("Name, e.g. Netflix", text: $viewModel.draftName)
                    .textFieldStyle(.roundedBorder)
                TextField("Amount", text: $viewModel.draftAmountText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                Picker("Period", selection: $viewModel.draftPeriod) {
                    ForEach(BillingPeriod.allCases) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                DatePicker("Charge date", selection: $viewModel.draftNextChargeDate, displayedComponents: .date)
            }
            .padding(.horizontal, 24)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Spacer()

            Button {
                Task {
                    if await viewModel.addDraftSubscription() {
                        viewModel.goToNextStep()
                    }
                }
            } label: {
                Text("Add")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColor.primary)
            .disabled(viewModel.isSaving)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

private struct LoadRevealStepView: View {
    let viewModel: OnboardingViewModel
    let onFinish: () -> Void

    var body: some View {
        OnboardingScaffold(title: "See the load instantly", ctaTitle: "Get Started", isDisabled: false, action: onFinish) {
            VStack(spacing: 16) {
                Text(CurrencyFormatter.format(viewModel.monthlyTotal, currencyCode: "EUR"))
                    .font(.system(size: 44, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(AppColor.text)
                Text("per month")
                    .font(.caption)
                    .foregroundStyle(AppColor.secondary)

                VStack(spacing: 6) {
                    ForEach(viewModel.subscriptions.prefix(3)) { subscription in
                        HStack {
                            Text(subscription.name)
                                .foregroundStyle(AppColor.text)
                            Spacer()
                            Text(CurrencyFormatter.format(subscription.amount, currencyCode: subscription.currencyCode))
                                .foregroundStyle(AppColor.secondary)
                        }
                        .font(.subheadline)
                    }
                }
                .padding(12)
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24)
            }
        }
    }
}

#if DEBUG
#Preview {
    OnboardingView(dependencies: PreviewSupport.dependencies, onFinish: {})
}
#endif
