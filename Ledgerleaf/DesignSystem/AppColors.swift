import SwiftUI

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

/// Design tokens for Ledgerleaf, sourced from the concept's Visual Direction spec.
enum AppColor {
    static let primary = Color(hex: "#0F3D2E")
    static let secondary = Color(hex: "#7E8B85")
    static let accent = Color(hex: "#D9F26B")
    static let background = Color(hex: "#FFFFFF")
    static let surface = Color(hex: "#F4F6F4")
    static let text = Color(hex: "#102019")
}
