import Foundation
import SwiftData
import SwiftUI

/// ViewModel for formula-related operations
@MainActor
@Observable
class FormulaViewModel {
    var formulas: [Formula] = []
    var selectedFormula: Formula?

    /// Load formulas for a specific subcategory
    func loadFormulas(for subcategory: Subcategory) {
        formulas = subcategory.sortedFormulas
    }

    /// Toggle favorite status of a formula
    func toggleFavorite(_ formula: Formula, modelContext: ModelContext) {
        formula.isFavorite.toggle()
        try? modelContext.save()
        HapticFeedback.selection()
    }

    /// Add a note to a formula
    func addNote(to formula: Formula, text: String, modelContext: ModelContext) {
        let note = UserNote(noteText: text, formula: formula)
        modelContext.insert(note)
        try? modelContext.save()
    }

    /// Delete a note
    func deleteNote(_ note: UserNote, modelContext: ModelContext) {
        modelContext.delete(note)
        try? modelContext.save()
    }
}
