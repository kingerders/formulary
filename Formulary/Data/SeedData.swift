import Foundation

/// Helper to trigger seed data loading at app startup.
/// The actual seeding logic is in DataService.swift.
/// This file can be used for any additional static data helpers.

enum SeedDataHelper {
    /// Category names and icons for reference (matches formulary_data.json)
    static let categoryInfo: [(name: String, icon: String)] = [
        ("Mathematics", "📐"),
        ("Physics", "⚛️"),
        ("Chemistry", "🧪"),
        ("Geometry", "📏"),
        ("Environmental Engineering", "🌿"),
        ("Geological Engineering", "🪨"),
        ("Chemical Engineering", "🏭"),
        ("Mechanical Engineering", "⚙️"),
        ("Electrical Engineering", "⚡"),
        ("Civil Engineering", "🏗️"),
        ("Geophysics", "🌍"),
        ("Geochemistry", "🔬"),
        ("Biology & Biomedical Engineering", "🧬"),
        ("Computer Science", "💻"),
        ("Meteorology & Atmospheric Science", "🌦️"),
        ("Astronomy & Astrophysics", "🔭"),
    ]
}
