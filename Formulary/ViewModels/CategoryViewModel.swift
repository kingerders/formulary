import Foundation
import SwiftData
import SwiftUI

/// ViewModel for the home screen category grid
@MainActor
@Observable
class CategoryViewModel {
    var categories: [Category] = []
    var isLoading = true

    func loadCategories(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.order)]
        )

        do {
            categories = try modelContext.fetch(descriptor)
            isLoading = false
        } catch {
            print("❌ Error loading categories: \(error)")
            isLoading = false
        }
    }
}
