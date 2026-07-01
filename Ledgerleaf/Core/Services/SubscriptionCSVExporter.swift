import Foundation

/// Builds a CSV representation of subscriptions for the Settings export/share flow.
struct SubscriptionCSVExporter: SubscriptionCSVExporting {
    func export(_ subscriptions: [Subscription]) -> String {
        var rows = ["Name,Amount,Currency,Period,Next Charge"]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for subscription in subscriptions {
            let fields = [
                csvField(subscription.name),
                csvField("\(subscription.amount)"),
                csvField(subscription.currencyCode),
                csvField(subscription.period.displayName),
                csvField(dateFormatter.string(from: subscription.nextChargeDate))
            ]
            rows.append(fields.joined(separator: ","))
        }

        return rows.joined(separator: "\n")
    }

    private func csvField(_ value: String) -> String {
        guard value.contains(",") || value.contains("\"") || value.contains("\n") else { return value }
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
