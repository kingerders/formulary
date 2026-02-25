import SwiftUI
import SwiftData

/// Notes view showing all user notes organized by category
struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var notesByCategory: [(category: Category, notes: [(formula: Formula, note: UserNote)])] = []

    var body: some View {
        Group {
            if notesByCategory.isEmpty {
                emptyState
            } else {
                notesList
            }
        }
        .background(notesByCategory.isEmpty ? Color.white : Color(.systemGroupedBackground))
        .navigationTitle("Notes")
        .onAppear { loadNotes() }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "note.text")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(Color.appPrimary.opacity(0.5))
            }

            VStack(spacing: 8) {
                Text("No Notes Yet")
                    .font(.qTitle3)
                Text("Add notes to any formula and\nthey'll appear here organized by category.")
                    .font(.qSubheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
    }

    // MARK: - Notes List

    private var notesList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(Array(notesByCategory.enumerated()), id: \.element.category.id) { index, group in
                    VStack(alignment: .leading, spacing: 10) {
                        // Category header
                        HStack(spacing: 10) {
                            Text(group.category.icon)
                                .font(.system(size: 22))
                            Text(group.category.name)
                                .font(.qHeadline)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("\(group.notes.count)")
                                .font(.qCaption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.categoryGradient(for: categoryIndex(for: group.category) ?? index))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                        // Notes for this category
                        VStack(spacing: 0) {
                            ForEach(Array(group.notes.enumerated()), id: \.element.note.id) { noteIndex, pair in
                                NavigationLink(value: pair.formula) {
                                    NoteCategoryRow(
                                        formula: pair.formula,
                                        note: pair.note,
                                        colorScheme: colorScheme
                                    )
                                }
                                .buttonStyle(.plain)

                                if noteIndex < group.notes.count - 1 {
                                    Divider()
                                        .padding(.leading, 46)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(colorScheme == .dark ? Color(.secondarySystemGroupedBackground) : .white)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .navigationDestination(for: Formula.self) { formula in
            FormulaDetailView(formula: formula)
        }
    }

    // MARK: - Helpers

    private func loadNotes() {
        let noteDescriptor = FetchDescriptor<UserNote>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        guard let allNotes = try? modelContext.fetch(noteDescriptor) else { return }

        let catDescriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.order)])
        guard let categories = try? modelContext.fetch(catDescriptor) else { return }

        var result: [(category: Category, notes: [(formula: Formula, note: UserNote)])] = []

        for cat in categories {
            var catNotes: [(formula: Formula, note: UserNote)] = []
            for note in allNotes {
                if let formula = note.formula,
                   let sub = formula.subcategory,
                   let noteCat = sub.category,
                   noteCat.id == cat.id {
                    catNotes.append((formula: formula, note: note))
                }
            }
            if !catNotes.isEmpty {
                result.append((category: cat, notes: catNotes))
            }
        }

        notesByCategory = result
    }

    private func categoryIndex(for category: Category) -> Int? {
        let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.order)])
        guard let categories = try? modelContext.fetch(descriptor) else { return nil }
        return categories.firstIndex { $0.id == category.id }
    }
}

// MARK: - Note Row for Category View

struct NoteCategoryRow: View {
    let formula: Formula
    let note: UserNote
    let colorScheme: ColorScheme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "note.text")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Color.appPrimary.opacity(0.7).gradient)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(formula.title)
                    .font(.qCaption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(note.noteText)
                    .font(.qCaption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.quicksand(9, weight: .medium))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.quaternary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        NotesView()
    }
    .modelContainer(for: [Category.self, Subcategory.self, Formula.self, UserNote.self], inMemory: true)
}
