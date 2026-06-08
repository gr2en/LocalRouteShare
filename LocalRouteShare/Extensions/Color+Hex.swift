import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red: UInt64
        let green: UInt64
        let blue: UInt64
        let alpha: UInt64

        switch hex.count {
        case 3:
            red = (int >> 8) * 17
            green = (int >> 4 & 0xF) * 17
            blue = (int & 0xF) * 17
            alpha = 255
        case 6:
            red = int >> 16
            green = int >> 8 & 0xFF
            blue = int & 0xFF
            alpha = 255
        case 8:
            red = int >> 24
            green = int >> 16 & 0xFF
            blue = int >> 8 & 0xFF
            alpha = int & 0xFF
        default:
            red = 0
            green = 0
            blue = 0
            alpha = 255
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }

    static let primaryPurple = Color(hex: "#6155F5")
    static let primaryBlue = Color(hex: "#51A2FF")
    static let buttonBlue = Color(hex: "#2B7FFF")
    static let textPrimary = Color(hex: "#101828")
    static let textSecondary = Color(hex: "#6A7282")
    static let lightGray = Color(hex: "#F3F4F6")
    static let borderGray = Color(hex: "#E5E7EB")
    static let backgroundGray = Color(hex: "#F9FAFB")
}
