import SwiftUI

/// Bottom-sheet form for adding or editing a single subscription.
struct AddEditSubscriptionSheet: View {
    @State var viewModel: AddEditSubscriptionViewModel
    let onSaved: () -> Void
    @Environment(\.dismiss) private var dismiss
    @FocusState private var amountFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Netflix", text: $viewModel.name)
                        .textInputAutocapitalization(.words)
                }

                Section("Amount and period") {
                    TextField("0.00", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                        .focused($amountFieldFocused)
                    Picker("Period", selection: $viewModel.period) {
                        ForEach(BillingPeriod.allCases) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Next charge") {
                    DatePicker("Date", selection: $viewModel.nextChargeDate, displayedComponents: .date)
                    Toggle("Remind before charge", isOn: $viewModel.isReminderEnabled)
                }

                Section("Notes") {
                    TextField("Optional", text: $viewModel.notes, axis: .vertical)
                }

                if viewModel.yearlySavingsPreview > 0 {
                    Section {
                        Label(
                            "Cancel it and save \(CurrencyFormatter.format(viewModel.yearlySavingsPreview, currencyCode: "EUR"))/year",
                            systemImage: "leaf"
                        )
                        .font(.footnote)
                        .foregroundStyle(AppColor.secondary)
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.background)
            .navigationTitle(viewModel.isEditing ? "Edit Subscription" : "Add Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.isEditing ? "Save" : "Add") {
                        Task {
                            if await viewModel.save() {
                                onSaved()
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving)
                    .fontWeight(.semibold)
                }
            }
        }
        .tint(AppColor.primary)
    }
}

#Preview {
    AddEditSubscriptionSheet(
        viewModel: PreviewSupport.dependencies.makeAddEditSubscriptionViewModel(editing: nil),
        onSaved: {}
    )
}
