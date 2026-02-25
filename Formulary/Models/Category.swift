import Foundation
import SwiftData

/// Represents a top-level discipline category (e.g., Mathematics, Physics)
@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var order: Int
    var isPremium: Bool

    @Relationship(deleteRule: .cascade, inverse: \Subcategory.category)
    var subcategories: [Subcategory] = []

    var sortedSubcategories: [Subcategory] {
        subcategories.sorted { $0.order < $1.order }
    }

    var formulaCount: Int {
        subcategories.reduce(0) { $0 + $1.formulas.count }
    }

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        order: Int,
        isPremium: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.order = order
        self.isPremium = isPremium
    }
}
