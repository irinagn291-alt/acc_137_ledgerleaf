import SwiftUI
import Charts

/// The "Insights" tab: month/year totals and analytics by period and by subscription.
struct InsightsView: View {
    let dependencies: AppDependencies
    @State private var viewModel: InsightsViewModel
    @State private var isStatisticsPresented = false

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        self._viewModel = State(initialValue: dependencies.makeInsightsViewModel())
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.subscriptionCount == 0 {
                    ContentUnavailableView {
                        Label("Nothing here yet", systemImage: "chart.bar")
                    } description: {
                        Text("Add your first subscription to see your monthly load instantly.")
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            totalsSummary
                            spendTrendSection
                            periodChartSection
                            topSubscriptionsChartSection
                            currencyBreakdownSection
                            forecastSection
                            statisticsLinkSection
                        }
                        .padding(16)
                    }
                }
            }
            .background(AppColor.background)
            .navigationTitle("Insights")
            .navigationDestination(isPresented: $isStatisticsPresented) {
                StatisticsView(dependencies: dependencies)
            }
        }
        .onAppear { viewModel.load() }
    }

    private var totalsSummary: some View {
        HStack(spacing: 12) {
            SummaryCard(title: "Monthly", value: CurrencyFormatter.format(viewModel.totals.monthlyTotal, currencyCode: "EUR"))
            SummaryCard(title: "Yearly", value: CurrencyFormatter.format(viewModel.totals.yearlyTotal, currencyCode: "EUR"))
        }
    }

    @ViewBuilder
    private var spendTrendSection: some View {
        if viewModel.spendTrend.count > 1 {
            VStack(alignment: .leading, spacing: 8) {
                Text("Spend trend")
                    .font(.headline)
                    .foregroundStyle(AppColor.text)
                Chart(viewModel.spendTrend) { point in
                    AreaMark(
                        x: .value("Month", point.monthDate, unit: .month),
                        y: .value("Monthly (€)", NSDecimalNumber(decimal: point.total).doubleValue)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppColor.accent.opacity(0.35))
                    LineMark(
                        x: .value("Month", point.monthDate, unit: .month),
                        y: .value("Monthly (€)", NSDecimalNumber(decimal: point.total).doubleValue)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppColor.primary)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
                .frame(height: 160)
            }
            .padding(16)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    @ViewBuilder
    private var currencyBreakdownSection: some View {
        if viewModel.currencyBreakdown.count > 1 {
            VStack(alignment: .leading, spacing: 8) {
                Text("By currency")
                    .font(.headline)
                    .foregroundStyle(AppColor.text)
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
            .padding(16)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var statisticsLinkSection: some View {
        Button {
            isStatisticsPresented = true
        } label: {
            HStack {
                Label("Full statistics", systemImage: "chart.pie")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .foregroundStyle(AppColor.text)
        }
        .padding(16)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var periodChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Load by period")
                .font(.headline)
                .foregroundStyle(AppColor.text)
            Chart(viewModel.periodBreakdown) { entry in
                BarMark(
                    x: .value("Period", entry.period.displayName),
                    y: .value("Monthly (€)", NSDecimalNumber(decimal: entry.monthlyEquivalentTotal).doubleValue)
                )
                .foregroundStyle(AppColor.primary)
                .cornerRadius(4)
            }
            .frame(height: 180)
        }
        .padding(16)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var topSubscriptionsChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Priciest subscriptions")
                .font(.headline)
                .foregroundStyle(AppColor.text)
            Chart(viewModel.topSubscriptions) { entry in
                BarMark(
                    x: .value("Monthly (€)", NSDecimalNumber(decimal: entry.monthlyEquivalentAmount).doubleValue),
                    y: .value("Subscription", entry.name)
                )
                .foregroundStyle(AppColor.accent)
                .cornerRadius(4)
            }
            .frame(height: CGFloat(viewModel.topSubscriptions.count) * 36 + 20)
        }
        .padding(16)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("12-month forecast")
                .font(.headline)
                .foregroundStyle(AppColor.text)

            Chart(viewModel.forecast) { point in
                LineMark(
                    x: .value("Month", point.monthDate, unit: .month),
                    y: .value("Projected (€)", NSDecimalNumber(decimal: point.projectedTotal).doubleValue)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(AppColor.primary)
                PointMark(
                    x: .value("Month", point.monthDate, unit: .month),
                    y: .value("Projected (€)", NSDecimalNumber(decimal: point.projectedTotal).doubleValue)
                )
                .foregroundStyle(AppColor.primary)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: 2)) { _ in
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .frame(height: 180)
        }
        .padding(16)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct SummaryCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColor.secondary)
            Text(value)
                .font(.title3.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(AppColor.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    InsightsView(dependencies: PreviewSupport.dependencies)
}
