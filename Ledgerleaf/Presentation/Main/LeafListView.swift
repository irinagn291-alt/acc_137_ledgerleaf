import SwiftUI

/// Identifies which subscription (if any) the add/edit sheet should open with.
private struct EditingTarget: Identifiable {
    let id = UUID()
    let subscription: Subscription?
}

/// The "Leaf" tab: month-total header, upcoming-charges timeline, and the subscription list.
struct LeafListView: View {
    let dependencies: AppDependencies
    @State private var viewModel: LeafListViewModel
    @State private var editingTarget: EditingTarget?
    @State private var subscriptionToCancelSavings: Subscription?

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        self._viewModel = State(initialValue: dependencies.makeLeafListViewModel())
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Leaf")
                .searchable(text: $viewModel.searchText, prompt: "Search subscriptions")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            editingTarget = EditingTarget(subscription: nil)
                        } label: {
                            Label("Add subscription", systemImage: "plus")
                        }
                    }
                }
                .background(AppColor.background)
        }
        .onAppear { viewModel.load() }
        .sheet(item: $editingTarget) { target in
            AddEditSubscriptionSheet(
                viewModel: dependencies.makeAddEditSubscriptionViewModel(editing: target.subscription),
                onSaved: { viewModel.load() }
            )
        }
        .alert(
            "If you cancel",
            isPresented: Binding(
                get: { subscriptionToCancelSavings != nil },
                set: { if !$0 { subscriptionToCancelSavings = nil } }
            ),
            presenting: subscriptionToCancelSavings
        ) { _ in
            Button("Got it", role: .cancel) { subscriptionToCancelSavings = nil }
        } message: { subscription in
            let savings = viewModel.cancelSavings(for: subscription)
            Text("Cancel \"\(subscription.name)\" and save \(CurrencyFormatter.format(savings, currencyCode: subscription.currencyCode))/year.")
        }
        .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isEmpty {
            EmptyLeafListView(onLoadSampleData: { viewModel.loadSampleData() })
        } else {
            List {
                Section {
                    MonthTotalHeaderView(totals: viewModel.totals)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }

                if !viewModel.upcomingCharges.isEmpty {
                    Section("Upcoming charges") {
                        UpcomingChargesTimelineView(subscriptions: viewModel.upcomingCharges)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }

                Section("All subscriptions") {
                    ForEach(viewModel.filteredSubscriptions) { subscription in
                        SubscriptionRowView(subscription: subscription, weight: viewModel.weight(for: subscription))
                            .contentShape(Rectangle())
                            .onTapGesture { editingTarget = EditingTarget(subscription: subscription) }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task { await viewModel.delete(subscription) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    subscriptionToCancelSavings = subscription
                                } label: {
                                    Label("If cancelled", systemImage: "leaf")
                                }
                                .tint(AppColor.primary)
                            }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppColor.background)
        }
    }
}

private struct EmptyLeafListView: View {
    let onLoadSampleData: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Nothing here yet", systemImage: "leaf")
        } description: {
            Text("Add your first subscription to see your monthly load instantly.")
        } actions: {
            Button("Try with sample data", action: onLoadSampleData)
                .font(.subheadline.weight(.semibold))
        }
    }
}

private struct MonthTotalHeaderView: View {
    let totals: SubscriptionTotals

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Monthly load")
                .font(.subheadline)
                .foregroundStyle(AppColor.secondary)
            Text(CurrencyFormatter.format(totals.monthlyTotal, currencyCode: "EUR"))
                .font(.system(.largeTitle, design: .default, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(AppColor.text)
            Text("\(CurrencyFormatter.format(totals.yearlyTotal, currencyCode: "EUR")) / year")
                .font(.footnote)
                .foregroundStyle(AppColor.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    LeafListView(dependencies: PreviewSupport.dependencies)
}
