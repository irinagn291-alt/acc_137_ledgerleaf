import SwiftUI
import SwiftData

@main
struct LedgerleafApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema(AppSchema.allModels)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
