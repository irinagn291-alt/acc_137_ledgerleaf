import SwiftUI

/// The app's minimal 2-tab navigation: Leaf (list) and Insights (analytics).
struct MainTabView: View {
    let dependencies: AppDependencies

    var body: some View {
        TabView {
            LeafListView(dependencies: dependencies)
                .tabItem { Label("Leaf", systemImage: "leaf") }

            InsightsView(dependencies: dependencies)
                .tabItem { Label("Insights", systemImage: "chart.bar.xaxis") }
        }
        .tint(AppColor.primary)
    }
}

#if DEBUG
#Preview {
    MainTabView(dependencies: PreviewSupport.dependencies)
}
#endif
