import SwiftUI
import Charts

/// Full statistics breakdown reached from Insights: headline numbers, ranked spend
/// share per subscription, currency distribution, and the near-term charge load.
struct StatisticsView: View {
    @State private var viewModel: StatisticsViewModel

    init(dependencies: AppDependencies) {
        self._viewModel = State(initialValue: dependencies.makeStatisticsViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headlineCards
                if !viewModel.currencyBreakdown.isEmpty {
                    currencySection
                }
                if !viewModel.rankedByShare.isEmpty {
                    rankedSection
                }
                next30DaysSection
            }
            .padding(16)
        }
        .background(AppColor.background)
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.load() }
    }

    private var headlineCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Subscriptions", value: "\(viewModel.subscriptionCount)")
            StatCard(title: "Average / month", value: CurrencyFormatter.format(viewModel.averageMonthlyCost, currencyCode: "EUR"))
            if let mostExpensive = viewModel.mostExpensive {
                StatCard(
                    title: "Priciest",
                    value: mostExpensive.name,
                    detail: CurrencyFormatter.format(mostExpensive.monthlyEquivalent, currencyCode: mostExpensive.currencyCode) + "/mo"
                )
            }
            if let cheapest = viewModel.cheapest {
                StatCard(
                    title: "Cheapest",
                    value: cheapest.name,
                    detail: CurrencyFormatter.format(cheapest.monthlyEquivalent, currencyCode: cheapest.currencyCode) + "/mo"
                )
            }
        }
    }

    private var currencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By currency")
                .font(.headline)
                .foregroundStyle(AppColor.text)

            Chart(viewModel.currencyBreakdown) { entry in
                SectorMark(
                    angle: .value("Monthly load", NSDecimalNumber(decimal: entry.monthlyTotal).doubleValue),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("Currency", entry.currencyCode))
                .cornerRadius(4)
            }
            .frame(height: 180)

            VStack(spacing: 8) {
                ForEach(viewModel.currencyBreakdown) { entry in
                    HStack {
                        Text(entry.currencyCode)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColor.text)
                        Text("\(entry.count) subscription\(entry.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(AppColor.secondary)
                        Spacer()
                        Text(CurrencyFormatter.format(entry.monthlyTotal, currencyCode: entry.currencyCode))
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(AppColor.text)
                    }
                }
            }
        }
        .padding(16)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var rankedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Share of monthly load")
                .font(.headline)
                .foregroundStyle(AppColor.text)

            ForEach(viewModel.rankedByShare) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(entry.subscription.name)
                            .font(.subheadline)
                            .foregroundStyle(AppColor.text)
                        Spacer()
                        Text(CurrencyFormatter.format(entry.subscription.monthlyEquivalent, currencyCode: entry.subscription.currencyCode))
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(AppColor.secondary)
                    }
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(AppColor.background)
                            Capsule().fill(AppColor.primary)
                                .frame(width: proxy.size.width * entry.shareOfTotal)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding(16)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var next30DaysSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Next 30 days")
                .font(.headline)
                .foregroundStyle(AppColor.text)
            Text("\(viewModel.next30DaysCount) charge\(viewModel.next30DaysCount == 1 ? "" : "s") coming up")
                .font(.subheadline)
                .foregroundStyle(AppColor.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    var detail: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColor.secondary)
            Text(value)
                .font(.subheadline.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(AppColor.text)
            if let detail {
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(AppColor.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NavigationStack {
        StatisticsView(dependencies: PreviewSupport.dependencies)
    }
}
