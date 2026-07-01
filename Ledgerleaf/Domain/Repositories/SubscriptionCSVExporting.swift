import Foundation

/// Abstracts CSV serialization of subscriptions for the Settings export/share flow.
protocol SubscriptionCSVExporting {
    func export(_ subscriptions: [Subscription]) -> String
}
