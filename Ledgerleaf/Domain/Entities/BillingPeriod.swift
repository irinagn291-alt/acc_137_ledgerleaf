import Foundation

/// How often a subscription charge recurs.
enum BillingPeriod: String, Codable, CaseIterable, Identifiable, Sendable {
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    /// Average number of times this period occurs within a calendar month.
    /// Weekly uses 52/12 weeks-per-month to avoid under-counting leap weeks.
    var occurrencesPerMonth: Double {
        switch self {
        case .weekly: return 52.0 / 12.0
        case .monthly: return 1
        case .yearly: return 1.0 / 12.0
        }
    }

    var occurrencesPerYear: Double {
        switch self {
        case .weekly: return 52
        case .monthly: return 12
        case .yearly: return 1
        }
    }

    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }

    var shortLabel: String {
        switch self {
        case .weekly: return "wk"
        case .monthly: return "mo"
        case .yearly: return "yr"
        }
    }
}
