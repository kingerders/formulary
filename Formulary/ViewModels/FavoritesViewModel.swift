import Foundation
import SwiftData
import SwiftUI

/// ViewModel for favorites management
@MainActor
@Observable
class FavoritesViewModel {
    var favorites: [Formula] = []

    func loadFavorites(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Formula>(
            predicate: #Predicate { $0.isFavorite == true },
            sortBy: [SortDescriptor(\.title)]
        )

        do {
            favorites = try modelContext.fetch(descriptor)
        } catch {
            print("❌ Error loading favorites: \(error)")
        }
    }

    func removeFavorite(_ formula: Formula, modelContext: ModelContext) {
        formula.isFavorite = false
        try? modelContext.save()
        loadFavorites(modelContext: modelContext)
    }
}
