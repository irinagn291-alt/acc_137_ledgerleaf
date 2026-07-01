import Foundation

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

/// Drives Settings: appearance, CSV export, and data reset.
@MainActor
@Observable
final class SettingsViewModel {
    var errorMessage: String?
    private(set) var exportURL: URL?
    private(set) var subscriptionCount = 0

    private let fetchSubscriptions: FetchSubscriptionsUseCase
    private let exportCSV: ExportSubscriptionsCSVUseCase
    private let seedSampleData: SeedSampleDataUseCase

    init(
        fetchSubscriptions: FetchSubscriptionsUseCase,
        exportCSV: ExportSubscriptionsCSVUseCase,
        seedSampleData: SeedSampleDataUseCase
    ) {
        self.fetchSubscriptions = fetchSubscriptions
        self.exportCSV = exportCSV
        self.seedSampleData = seedSampleData
    }

    func load() {
        subscriptionCount = (try? fetchSubscriptions.execute().count) ?? 0
    }

    /// Populates the tracker with realistic demo subscriptions — useful to preview
    /// Insights/Statistics fully populated without entering data by hand.
    func loadSampleData() {
        do {
            try seedSampleData.execute()
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func prepareExport() {
        do {
            let subscriptions = try fetchSubscriptions.execute()
            exportURL = try exportCSV.execute(subscriptions: subscriptions)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
