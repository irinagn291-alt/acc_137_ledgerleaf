import SwiftUI

/// Settings: appearance, CSV export/share, sample data, and about/reset.
struct SettingsView: View {
    let dependencies: AppDependencies
    @State private var viewModel: SettingsViewModel
    @AppStorage("appearanceMode") private var appearanceModeRawValue = AppearanceMode.system.rawValue
    @State private var isShareSheetPresented = false
    @State private var isResetConfirmationPresented = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        self._viewModel = State(initialValue: dependencies.makeSettingsViewModel())
    }

    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRawValue) ?? .system
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $appearanceModeRawValue) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.displayName).tag(mode.rawValue)
                        }
                    }
                }

                Section("Data") {
                    Button {
                        viewModel.prepareExport()
                        isShareSheetPresented = viewModel.exportURL != nil
                    } label: {
                        Label("Export to CSV", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        isResetConfirmationPresented = true
                    } label: {
                        Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                    }
                }

                if viewModel.subscriptionCount == 0 {
                    Section("Demo Data") {
                        Button {
                            viewModel.loadSampleData()
                        } label: {
                            Label("Load sample subscriptions", systemImage: "sparkles")
                        }
                        Text("Adds a realistic set of subscriptions so Leaf and Insights aren't empty.")
                            .font(.caption)
                            .foregroundStyle(AppColor.secondary)
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: Bundle.main.appVersionString)
                    Text("Estimates are approximate and not financial advice.")
                        .font(.caption)
                        .foregroundStyle(AppColor.secondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.background)
            .navigationTitle("Settings")
            .onAppear { viewModel.load() }
            .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .confirmationDialog("Reset onboarding?", isPresented: $isResetConfirmationPresented, titleVisibility: .visible) {
                Button("Reset", role: .destructive) { hasCompletedOnboarding = false }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your subscriptions will stay, but onboarding will show again.")
            }
            .sheet(isPresented: $isShareSheetPresented) {
                if let exportURL = viewModel.exportURL {
                    ShareSheet(activityItems: [exportURL])
                }
            }
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private extension Bundle {
    var appVersionString: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#if DEBUG
#Preview {
    SettingsView(dependencies: PreviewSupport.dependencies)
}
#endif
