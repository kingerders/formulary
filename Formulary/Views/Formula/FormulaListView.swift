import SwiftUI
import SwiftData

/// A scrollable list of formulas, typically used for browsing within a subcategory
struct FormulaListView: View {
    let subcategory: Subcategory
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = FormulaViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.formulas) { formula in
                    NavigationLink(value: formula) {
                        FormulaCardView(formula: formula)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(subcategory.name)
        .navigationDestination(for: Formula.self) { formula in
            FormulaDetailView(formula: formula)
        }
        .onAppear {
            viewModel.loadFormulas(for: subcategory)
        }
    }
}

#Preview {
    let subcategory = Subcategory(name: "Algebra", order: 0)
    NavigationStack {
        FormulaListView(subcategory: subcategory)
    }
    .modelContainer(for: [Category.self, Subcategory.self, Formula.self, UserNote.self], inMemory: true)
}
