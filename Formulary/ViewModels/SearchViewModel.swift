import Foundation
import SwiftData
import SwiftUI

/// ViewModel for global search functionality
@MainActor
@Observable
class SearchViewModel {
    var searchText = ""
    var results: [Formula] = []
    var isSearching = false
    var selectedLevel: FormulaLevel?

    private var searchTask: Task<Void, Never>?

    func search(modelContext: ModelContext) {
        searchTask?.cancel()

        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            isSearching = false
            return
        }

        isSearching = true

        searchTask = Task {
            // Small delay for debouncing
            try? await Task.sleep(for: .milliseconds(200))

            guard !Task.isCancelled else { return }

            let searchResults = SearchService.shared.search(
                query: searchText,
                level: selectedLevel,
                modelContext: modelContext
            )

            if !Task.isCancelled {
                results = searchResults
                isSearching = false
            }
        }
    }

    func clearSearch() {
        searchText = ""
        results = []
        selectedLevel = nil
        isSearching = false
    }
}
