import SwiftUI
import SwiftData

/// Professional search view with real-time filtering, level chips, and rich results
struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SearchViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Level filter chips
            levelFilterBar

            // Results
            if viewModel.searchText.isEmpty {
                emptySearchState
            } else if viewModel.isSearching {
                loadingState
            } else if viewModel.results.isEmpty {
                noResultsState
            } else {
                resultsList
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Search")
        .searchable(text: $viewModel.searchText, prompt: "Search formulas, topics, tags...")
        .onChange(of: viewModel.searchText) {
            viewModel.search(modelContext: modelContext)
        }
        .onChange(of: viewModel.selectedLevel) {
            viewModel.search(modelContext: modelContext)
        }
    }

    // MARK: - Level Filter Bar

    private var levelFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All Levels",
                    isSelected: viewModel.selectedLevel == nil,
                    color: .appPrimary
                ) {
                    viewModel.selectedLevel = nil
                }

                ForEach(FormulaLevel.allCases, id: \.self) { level in
                    FilterChip(
                        title: level.displayName,
                        isSelected: viewModel.selectedLevel == level,
                        color: levelColor(level)
                    ) {
                        viewModel.selectedLevel = level
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - States

    private var emptySearchState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.quaternary)
            VStack(spacing: 6) {
                Text("Search Formulas")
                    .font(.qHeadline)
                    .foregroundStyle(.primary)
                Text("Search across all formulas by name,\ndescription, variables, or tags.")
                    .font(.qSubheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
    }

    private var loadingState: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Spacer()
        }
    }

    private var noResultsState: some View {
        ContentUnavailableView.search(text: viewModel.searchText)
    }

    private var resultsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                // Results count
                HStack {
                    Text("\(viewModel.results.count) results")
                        .font(.qCaption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

                ForEach(viewModel.results) { formula in
                    NavigationLink(value: formula) {
                        SearchResultRow(formula: formula)
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .padding(.leading, 20)
                }
            }
        }
        .navigationDestination(for: Formula.self) { formula in
            FormulaDetailView(formula: formula)
        }
    }

    private func levelColor(_ level: FormulaLevel) -> Color {
        switch level {
        case .highSchool: return .levelHighSchool
        case .undergraduate: return .levelUndergrad
        case .graduate: return .levelGraduate
        case .professional: return .levelProfessional
        }
    }
}

/// Professional search result row with breadcrumb, LaTeX preview, and description
struct SearchResultRow: View {
    let formula: Formula
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 14) {
            // Color strip
            RoundedRectangle(cornerRadius: 2)
                .fill(levelColor.gradient)
                .frame(width: 4, height: 50)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(formula.title)
                        .font(.qSubheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Spacer()

                    LevelBadgeView(level: formula.level)
                }

                if let subcategory = formula.subcategory,
                   let category = subcategory.category {
                    HStack(spacing: 4) {
                        Text(category.icon)
                            .font(.system(size: 10))
                        Text("\(category.name) → \(subcategory.name)")
                            .font(.qCaption2)
                            .foregroundStyle(.secondary)
                    }
                }

                LaTeXTextView(latex: formula.latex, fontSize: 13, color: .secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private var levelColor: Color {
        switch formula.level {
        case .highSchool: return .levelHighSchool
        case .undergraduate: return .levelUndergrad
        case .graduate: return .levelGraduate
        case .professional: return .levelProfessional
        }
    }
}

/// Professional selectable filter chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .appPrimary
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
            HapticFeedback.light()
        }) {
            Text(title)
                .font(.qCaption)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? color : Color(.tertiarySystemFill))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? color.opacity(0.3) : .clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
    .modelContainer(for: [Category.self, Subcategory.self, Formula.self, UserNote.self], inMemory: true)
}
