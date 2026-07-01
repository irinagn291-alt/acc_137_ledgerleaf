import Foundation

/// Shared money formatting so every screen displays amounts identically.
enum CurrencyFormatter {
    static func format(_ amount: Decimal, currencyCode: String) -> String {
        amount.formatted(.currency(code: currencyCode).locale(Locale(identifier: "en_US")))
    }
}
