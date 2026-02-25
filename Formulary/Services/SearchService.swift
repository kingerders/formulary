import Foundation
import SwiftData

/// Service for searching formulas across all categories
@MainActor
class SearchService {
    static let shared = SearchService()

    private init() {}

    /// Search formulas by query string across title, description, tags, and variables
    func search(query: String, modelContext: ModelContext) -> [Formula] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }

        let trimmedQuery = query.trimmingCharacters(in: .whitespaces).lowercased()

        let descriptor = FetchDescriptor<Formula>(
            sortBy: [SortDescriptor(\.title)]
        )

        guard let allFormulas = try? modelContext.fetch(descriptor) else {
            return []
        }

        return allFormulas.filter { formula in
            formula.title.lowercased().contains(trimmedQuery) ||
            formula.formulaDescription.lowercased().contains(trimmedQuery) ||
            formula.variables.lowercased().contains(trimmedQuery) ||
            formula.latex.lowercased().contains(trimmedQuery) ||
            formula.tags.contains { $0.lowercased().contains(trimmedQuery) }
        }
    }

    /// Search formulas filtered by level
    func search(query: String, level: FormulaLevel?, modelContext: ModelContext) -> [Formula] {
        var results = search(query: query, modelContext: modelContext)
        if let level = level {
            results = results.filter { $0.level == level }
        }
        return results
    }
}
