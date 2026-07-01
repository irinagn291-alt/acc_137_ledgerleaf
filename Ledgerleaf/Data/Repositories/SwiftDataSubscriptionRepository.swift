import Foundation
import SwiftData

/// Concrete `SubscriptionRepository` backed by a SwiftData `ModelContext`.
@MainActor
final class SwiftDataSubscriptionRepository: SubscriptionRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [Subscription] {
        let descriptor = FetchDescriptor<SubscriptionModel>(
            sortBy: [SortDescriptor(\.nextChargeDate, order: .forward)]
        )
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func add(_ subscription: Subscription) throws {
        let model = SubscriptionModel(domain: subscription)
        modelContext.insert(model)
        try modelContext.save()
    }

    func update(_ subscription: Subscription) throws {
        guard let model = try fetchModel(id: subscription.id) else { return }
        model.apply(subscription)
        try modelContext.save()
    }

    func delete(id: UUID) throws {
        guard let model = try fetchModel(id: id) else { return }
        modelContext.delete(model)
        try modelContext.save()
    }

    private func fetchModel(id: UUID) throws -> SubscriptionModel? {
        var descriptor = FetchDescriptor<SubscriptionModel>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
