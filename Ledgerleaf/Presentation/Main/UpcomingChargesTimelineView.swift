import SwiftUI

/// Horizontal "Leaf" timeline of the nearest upcoming charges — one of the spec's named hooks.
struct UpcomingChargesTimelineView: View {
    let subscriptions: [Subscription]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(subscriptions) { subscription in
                    LeafTimelineCard(subscription: subscription)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct LeafTimelineCard: View {
    let subscription: Subscription

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "leaf.fill")
                .font(.caption)
                .foregroundStyle(AppColor.primary)
            Text(subscription.name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.text)
                .lineLimit(1)
            Text(dateLabel)
                .font(.caption2)
                .foregroundStyle(AppColor.secondary)
            Text(CurrencyFormatter.format(subscription.amount, currencyCode: subscription.currencyCode))
                .font(.caption.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(AppColor.text)
        }
        .padding(10)
        .frame(width: 120, alignment: .leading)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var dateLabel: String {
        let days = subscription.daysUntilNextCharge()
        switch days {
        case ..<0: return "overdue"
        case 0: return "today"
        case 1: return "tomorrow"
        default: return "in \(days)d"
        }
    }
}

#Preview {
    UpcomingChargesTimelineView(subscriptions: [
        Subscription(name: "Netflix", amount: 11.99, period: .monthly, nextChargeDate: .now.addingTimeInterval(86400 * 2)),
        Subscription(name: "Spotify", amount: 9.99, period: .monthly, nextChargeDate: .now.addingTimeInterval(86400 * 5))
    ])
    .padding(.vertical)
    .background(AppColor.background)
}
