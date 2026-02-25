import Foundation
import SwiftData

/// Represents a subcategory within a discipline (e.g., Algebra, Calculus)
@Model
final class Subcategory {
    @Attribute(.unique) var id: UUID
    var name: String
    var order: Int

    var category: Category?

    @Relationship(deleteRule: .cascade, inverse: \Formula.subcategory)
    var formulas: [Formula] = []

    var sortedFormulas: [Formula] {
        formulas.sorted { $0.order < $1.order }
    }

    init(
        id: UUID = UUID(),
        name: String,
        order: Int,
        category: Category? = nil
    ) {
        self.id = id
        self.name = name
        self.order = order
        self.category = category
    }
}
