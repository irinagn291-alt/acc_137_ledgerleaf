import Foundation

/// Builds a shareable CSV file URL from the current subscriptions, for Settings export.
@MainActor
struct ExportSubscriptionsCSVUseCase {
    private let exporter: SubscriptionCSVExporting

    init(exporter: SubscriptionCSVExporting) {
        self.exporter = exporter
    }

    func execute(subscriptions: [Subscription]) throws -> URL {
        let csv = exporter.export(subscriptions)
        let directory = FileManager.default.temporaryDirectory
        let url = directory.appendingPathComponent("ledgerleaf-subscriptions-\(Int(Date().timeIntervalSince1970)).csv")
        try csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
