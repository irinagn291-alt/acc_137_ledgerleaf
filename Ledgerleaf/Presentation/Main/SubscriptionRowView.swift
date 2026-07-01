import SwiftUI

/// A single row in the Leaf list. The leading bar's color "weight" gets closer to the brand's
/// primary tone as the subscription's monthly cost approaches the most expensive one tracked.
struct SubscriptionRowView: View {
    let subscription: Subscription
    let weight: Double

    private var weightColor: Color {
        AppColor.secondary.mix(with: AppColor.primary, by: weight)
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(weightColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.body.weight(.medium))
                    .foregroundStyle(AppColor.text)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppColor.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(CurrencyFormatter.format(subscription.amount, currencyCode: subscription.currencyCode))
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(AppColor.text)
                Text(subscription.period.shortLabel)
                    .font(.caption2)
                    .foregroundStyle(AppColor.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var subtitle: String {
        let days = subscription.daysUntilNextCharge()
        let dayText: String
        switch days {
        case ..<0: dayText = "overdue"
        case 0: dayText = "today"
        case 1: dayText = "tomorrow"
        default: dayText = "in \(days)d"
        }
        if subscription.period != .monthly {
            return "\(dayText) · ≈ \(CurrencyFormatter.format(subscription.monthlyEquivalent, currencyCode: subscription.currencyCode))/mo"
        }
        return dayText
    }
}

private extension Color {
    /// Linear-interpolates between this color and `other`, used for the color-weight hook
    /// without introducing any hex value outside the approved `AppColor` palette.
    func mix(with other: Color, by fraction: Double) -> Color {
        let clamped = min(max(fraction, 0), 1)
        let resolvedSelf = self.resolve(in: .init())
        let resolvedOther = other.resolve(in: .init())
        return Color(
            red: Double(resolvedSelf.red) + (Double(resolvedOther.red) - Double(resolvedSelf.red)) * clamped,
            green: Double(resolvedSelf.green) + (Double(resolvedOther.green) - Double(resolvedSelf.green)) * clamped,
            blue: Double(resolvedSelf.blue) + (Double(resolvedOther.blue) - Double(resolvedSelf.blue)) * clamped
        )
    }
}

#Preview {
    List {
        SubscriptionRowView(
            subscription: Subscription(name: "Netflix", amount: 11.99, period: .monthly, nextChargeDate: .now.addingTimeInterval(86400 * 2)),
            weight: 0.4
        )
        SubscriptionRowView(
            subscription: Subscription(name: "Adobe Creative Cloud", amount: 599, period: .yearly, nextChargeDate: .now.addingTimeInterval(86400 * 40)),
            weight: 1.0
        )
    }
}
