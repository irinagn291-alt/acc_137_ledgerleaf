import SwiftUI
import SwiftData

/// Switches between onboarding and the main 2-tab app, and builds the single
/// `AppDependencies` instance shared by every screen.
struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("appearanceMode") private var appearanceModeRawValue = AppearanceMode.system.rawValue
    @Environment(\.modelContext) private var modelContext
    @State private var dependencies: AppDependencies?

    private var preferredColorScheme: ColorScheme? {
        switch AppearanceMode(rawValue: appearanceModeRawValue) ?? .system {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var body: some View {
        Group {
            if let dependencies {
                if hasCompletedOnboarding {
                    MainTabView(dependencies: dependencies)
                } else {
                    OnboardingView(dependencies: dependencies, onFinish: { hasCompletedOnboarding = true })
                }
            } else {
                Color(AppColor.background)
            }
        }
        .tint(AppColor.accent)
        .preferredColorScheme(preferredColorScheme)
        .onAppear {
            if dependencies == nil {
                dependencies = AppDependencies(modelContext: modelContext)
            }
        }
    }
}
