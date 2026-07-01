import Foundation
import SwiftData

#if DEBUG
/// In-memory dependency graph used only by SwiftUI `#Preview`s. Pre-seeded with
/// sample subscriptions so previews render populated Leaf/Insights/Statistics
/// screens instead of empty states.
@MainActor
enum PreviewSupport {
    static var dependencies: AppDependencies = {
        let schema = Schema(AppSchema.allModels)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let dependencies = AppDependencies(modelContext: container.mainContext)
        try? SeedSampleDataUseCase(repository: dependencies.subscriptionRepository).execute()
        return dependencies
    }()
}
#endif
