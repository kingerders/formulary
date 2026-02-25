import SwiftUI

// MARK: - App Color Theme

extension Color {
    // Primary palette
    static let appPrimary = Color(hex: "4F46E5")       // Deep Indigo
    static let appSecondary = Color(hex: "14B8A6")      // Teal
    static let appAccent = Color(hex: "F59E0B")         // Amber

    // Level badge colors
    static let levelHighSchool = Color(hex: "22C55E")   // Green
    static let levelUndergrad = Color(hex: "3B82F6")    // Blue
    static let levelGraduate = Color(hex: "A855F7")     // Purple
    static let levelProfessional = Color(hex: "EF4444") // Red

    // Card backgrounds
    static let cardBackground = Color(.systemBackground).opacity(0.95)

    // MARK: - Category Gradients

    static func categoryGradient(for index: Int) -> LinearGradient {
        let colors = categoryGradientColors(for: index)
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func categoryGradientColors(for index: Int) -> [Color] {
        switch index {
        case 0:  return [Color(hex: "6366F1"), Color(hex: "8B5CF6")] // Math: Indigo → Violet
        case 1:  return [Color(hex: "3B82F6"), Color(hex: "06B6D4")] // Physics: Blue → Cyan
        case 2:  return [Color(hex: "22C55E"), Color(hex: "10B981")] // Chemistry: Green → Emerald
        case 3:  return [Color(hex: "F97316"), Color(hex: "F59E0B")] // Geometry: Orange → Amber
        case 4:  return [Color(hex: "22C55E"), Color(hex: "84CC16")] // Environmental: Green → Lime
        case 5:  return [Color(hex: "78716C"), Color(hex: "92400E")] // Geological: Stone → Brown
        case 6:  return [Color(hex: "14B8A6"), Color(hex: "06B6D4")] // Chemical Eng: Teal → Cyan
        case 7:  return [Color(hex: "64748B"), Color(hex: "9CA3AF")] // Mechanical: Slate → Gray
        case 8:  return [Color(hex: "EAB308"), Color(hex: "F59E0B")] // Electrical: Yellow → Amber
        case 9:  return [Color(hex: "0EA5E9"), Color(hex: "3B82F6")] // Civil: Sky → Blue
        case 10: return [Color(hex: "F43F5E"), Color(hex: "EC4899")] // Geophysics: Rose → Pink
        case 11: return [Color(hex: "A855F7"), Color(hex: "D946EF")] // Geochemistry: Purple → Fuchsia
        case 12: return [Color(hex: "10B981"), Color(hex: "22C55E")] // Biology: Emerald → Green
        case 13: return [Color(hex: "8B5CF6"), Color(hex: "A855F7")] // CS: Violet → Purple
        case 14: return [Color(hex: "0EA5E9"), Color(hex: "6366F1")] // Meteorology: Sky → Indigo
        case 15: return [Color(hex: "475569"), Color(hex: "71717A")] // Astronomy: Slate → Zinc
        default: return [Color(hex: "6366F1"), Color(hex: "8B5CF6")]
        }
    }

    // MARK: - Hex Initializer

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
