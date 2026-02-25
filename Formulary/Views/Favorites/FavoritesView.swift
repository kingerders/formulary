import SwiftUI
import SwiftData

/// Professional favorites view with grouped display, sort options, and rich empty state
struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = FavoritesViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @State private var sortOrder: SortOrder = .alphabetical

    enum SortOrder: String, CaseIterable {
        case alphabetical = "A-Z"
        case level = "Level"
        case recent = "Recent"
    }

    var body: some View {
        Group {
            if viewModel.favorites.isEmpty {
                emptyState
            } else {
                favoritesList
            }
        }
        .background(viewModel.favorites.isEmpty ? Color.white : Color(.systemGroupedBackground))
        .navigationTitle("Favorites")
        .onAppear {
            viewModel.loadFavorites(modelContext: modelContext)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "heart")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(Color.appAccent.opacity(0.5))
            }

            VStack(spacing: 8) {
                Text("No Favorites Yet")
                    .font(.qTitle3)
                Text("Tap the heart icon on any formula\nto save it here for quick access.")
                    .font(.qSubheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
    }

    // MARK: - Favorites List

    private var favoritesList: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack {
                Text("\(viewModel.favorites.count) saved")
                    .font(.qCaption)
                    .foregroundStyle(.secondary)

                Spacer()

                // Sort picker
                Menu {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Button {
                            withAnimation { sortOrder = order }
                        } label: {
                            Label(order.rawValue, systemImage: sortOrder == order ? "checkmark" : "")
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption2)
                        Text(sortOrder.rawValue)
                            .font(.qCaption)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            // Formula cards
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(sortedFavorites) { formula in
                        NavigationLink(value: formula) {
                            FavoriteRow(formula: formula) {
                                withAnimation(.spring(response: 0.35)) {
                                    viewModel.removeFavorite(formula, modelContext: modelContext)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))

                        Divider()
                            .padding(.leading, 20)
                    }
                }
            }
        }
        .navigationDestination(for: Formula.self) { formula in
            FormulaDetailView(formula: formula)
        }
    }

    private var sortedFavorites: [Formula] {
        switch sortOrder {
        case .alphabetical:
            return viewModel.favorites.sorted { $0.title < $1.title }
        case .level:
            return viewModel.favorites.sorted { $0.level.sortIndex < $1.level.sortIndex }
        case .recent:
            return viewModel.favorites // already in insertion order
        }
    }
}

/// A rich favorites row with color accent, breadcrumb, and inline unfavorite
struct FavoriteRow: View {
    let formula: Formula
    let onRemove: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 14) {
            // Level color strip
            RoundedRectangle(cornerRadius: 2)
                .fill(levelColor.gradient)
                .frame(width: 4, height: 56)

            VStack(alignment: .leading, spacing: 5) {
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

            // Unfavorite button
            Button {
                onRemove()
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appAccent)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
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

#Preview {
    NavigationStack {
        FavoritesView()
    }
    .modelContainer(for: [Category.self, Subcategory.self, Formula.self, UserNote.self], inMemory: true)
}
