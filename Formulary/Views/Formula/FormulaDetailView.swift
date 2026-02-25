import SwiftUI
import SwiftData

/// Full-page detail view for a formula — compact, native rendering, collapsible sections
struct FormulaDetailView: View {
    let formula: Formula
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var newNoteText = ""
    @State private var showingNoteEditor = false
    @State private var relatedFormulas: [Formula] = []
    @State private var expandRelated = true
    @State private var expandNotes = true
    @State private var expandTags = true

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                heroHeader
                formulaBlock

                notesSection

                if !relatedFormulas.isEmpty {
                    CollapsibleCard(
                        icon: "link",
                        title: "Related Formulas (\(relatedFormulas.count))",
                        color: .green,
                        isExpanded: $expandRelated
                    ) {
                        relatedContent
                    }
                }

                if !formula.tags.isEmpty {
                    CollapsibleCard(
                        icon: "tag.fill",
                        title: "Tags",
                        color: .teal,
                        isExpanded: $expandTags
                    ) {
                        FlowLayout(spacing: 8) {
                            ForEach(formula.tags, id: \.self) { tag in
                                TagPill(tag: tag)
                            }
                        }
                    }
                }

                Spacer(minLength: 30)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(navBarBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(for: Formula.self) { formula in
            FormulaDetailView(formula: formula)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                favoriteButton
                shareButton
            }
        }
        .onAppear { loadRelatedFormulas() }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            categoryGradient
                .frame(height: 130)

            VStack(alignment: .leading, spacing: 5) {
                if let sub = formula.subcategory, let cat = sub.category {
                    HStack(spacing: 4) {
                        Text(cat.icon).font(.qCaption2)
                        Text(cat.name).font(.qCaption2)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 7, weight: .bold))
                        Text(sub.name).font(.qCaption2)
                    }
                    .foregroundStyle(.white.opacity(0.85))
                }

                Text(formula.title)
                    .font(.qHeadline)
                    .foregroundStyle(.white)
                    .lineLimit(3)

                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 1.5, style: .continuous).fill(.white).frame(width: 5, height: 5)
                        Text(formula.level.displayName)
                            .font(.qCaption2)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
                    .foregroundStyle(.white)

                    if formula.isPremium {
                        HStack(spacing: 3) {
                            Image(systemName: "crown.fill").font(.system(size: 8))
                            Text("Premium").font(.qCaption2)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                        .foregroundStyle(.white)
                    }
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// LinearGradient used both in the hero card and the navigation bar background
    private var navBarBackground: LinearGradient {
        if let sub = formula.subcategory,
           let cat = sub.category,
           let idx = categoryIndex(for: cat) {
            return LinearGradient(
                colors: Color.categoryGradientColors(for: idx),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color.appPrimary, Color.appPrimary.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var categoryGradient: some View {
        Group {
            if let sub = formula.subcategory,
               let cat = sub.category,
               let idx = categoryIndex(for: cat) {
                LinearGradient(
                    colors: Color.categoryGradientColors(for: idx),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [Color.appPrimary, Color.appPrimary.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    // MARK: - Formula Block (always open)

    private var formulaBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !formula.formulaDescription.isEmpty {
                Text(formula.formulaDescription)
                    .font(.quicksand(14, weight: .medium)) // Increased from qFootnote (13)
                    .foregroundStyle(.primary.opacity(0.85))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 10) // Reduced padding
                    .padding(.top, 14)
                    .padding(.bottom, 6)
            }

            if !formula.whatIsItFor.isEmpty {
                Text(formula.whatIsItFor)
                    .font(.quicksand(13, weight: .medium)) // Increased from qCaption (12)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 10) // Reduced padding
                    .padding(.top, formula.formulaDescription.isEmpty ? 14 : 2)
                    .padding(.bottom, 6)
            }

            Divider().padding(.horizontal, 10)

            DetailLaTeXView(latex: formula.latex, fontSize: 22)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)

            if !formula.variables.isEmpty {
                Divider()
                    .padding(.horizontal, 10) // Reduced padding
                    .padding(.top, 4)
                
                HStack(spacing: 6) {
                    Text("where:")
                        .font(.quicksand(15, weight: .bold))
                        .foregroundStyle(.primary.opacity(0.75))
                        .italic()
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.top, 12)
                .padding(.bottom, 6)
                
                variablesList
                    .padding(.horizontal, 10) // Reduced padding
                    .padding(.bottom, 14)
            } else {
                Spacer().frame(height: 8)
            }

            // Formula diagram image (Temporarily hidden per user request)
            /*
            if !formula.imageName.isEmpty,
               let uiImage = loadFormulaImage(named: formula.imageName) {
                Divider()
                    .padding(.horizontal, 16)
                
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            */
        }
        .background(cardFill)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func loadFormulaImage(named imageName: String) -> UIImage? {
        // Try loading from Assets catalog or main bundle root
        if let uiImage = UIImage(named: imageName) {
            return uiImage
        }
        
        // Fallback for direct file path in case it's stored in a subdirectory
        if let path = Bundle.main.path(forResource: imageName, ofType: "png", inDirectory: "FormulaImages"),
           let uiImage = UIImage(contentsOfFile: path) {
            return uiImage
        }

        return nil
    }

    private var variablesList: some View {
        let vars = parseVariables(formula.variables)
        return VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(vars.enumerated()), id: \.offset) { index, v in
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(v.symbol)
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(.primary)
                    
                    Text(":")
                        .font(.quicksand(14, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.6))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(v.name)
                            .font(.quicksand(14, weight: .semibold))
                            .foregroundStyle(.primary.opacity(0.7))
                        if let unit = v.unit {
                            Text("(\(unit))")
                                .font(.quicksand(13, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Related Content

    private var relatedContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(relatedFormulas.enumerated()), id: \.element.id) { index, related in
                NavigationLink(value: related) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.turn.down.right")
                            .font(.caption2)
                            .foregroundStyle(Color.green)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(related.title)
                                .font(.qCaption)
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            LaTeXTextView(latex: related.latex, fontSize: 11, color: .secondary)
                        }

                        Spacer()
                        LevelBadgeView(level: related.level)
                    }
                    .padding(.vertical, 7)
                }
                .buttonStyle(.plain)

                if index < relatedFormulas.count - 1 {
                    Divider().padding(.leading, 24)
                }
            }
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    expandNotes.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    // Prominent notes icon
                    Image(systemName: "note.text")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.indigo.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notes")
                            .font(.qSubheadline)
                            .foregroundStyle(.primary)
                        if !formula.notes.isEmpty {
                            Text("\(formula.notes.count) note\(formula.notes.count == 1 ? "" : "s")")
                                .font(.qCaption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.35)) {
                            showingNoteEditor.toggle()
                            if showingNoteEditor { expandNotes = true }
                        }
                    } label: {
                        Image(systemName: showingNoteEditor ? "xmark.circle.fill" : "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.appPrimary)
                    }

                    Image(systemName: expandNotes ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expandNotes {
                VStack(spacing: 8) {
                    if showingNoteEditor {
                        noteEditor
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if formula.notes.isEmpty && !showingNoteEditor {
                        HStack {
                            Spacer()
                            VStack(spacing: 6) {
                                Image(systemName: "text.bubble")
                                    .font(.subheadline)
                                    .foregroundStyle(.quaternary)
                                Text("No notes yet")
                                    .font(.qCaption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 14)
                            Spacer()
                        }
                    }

                    ForEach(formula.notes.sorted { $0.createdAt > $1.createdAt }) { note in
                        NoteRow(note: note) {
                            withAnimation {
                                modelContext.delete(note)
                                try? modelContext.save()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(cardFill)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.indigo.opacity(0.35), lineWidth: 1.5)
        )
        .shadow(color: Color.indigo.opacity(0.12), radius: 10, x: 0, y: 4)
    }

    private var noteEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            // TextEditor gives full system copy/paste/cut support
            TextEditor(text: $newNoteText)
                .font(.quicksand(14, weight: .medium))
                .frame(minHeight: 90)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    Group {
                        if newNoteText.isEmpty {
                            Text("Add a note... (supports paste from other apps)")
                                .font(.quicksand(13, weight: .medium))
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .allowsHitTesting(false)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                )

            HStack {
                Spacer()
                Button { saveNote() } label: {
                    Text("Save")
                        .font(.qCaption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.appPrimary)
                        .clipShape(Capsule())
                }
                .disabled(newNoteText.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(newNoteText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
        }
    }

    // MARK: - Toolbar

    private var favoriteButton: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                formula.isFavorite.toggle()
                try? modelContext.save()
                HapticFeedback.selection()
            }
        } label: {
            Image(systemName: formula.isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(formula.isFavorite ? Color.pink.opacity(0.9) : .white.opacity(0.9))
                .symbolEffect(.bounce, value: formula.isFavorite)
        }
    }

    private var shareButton: some View {
        ShareLink(item: shareText) {
            Image(systemName: "square.and.arrow.up")
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    // MARK: - Helpers

    private var cardFill: Color {
        colorScheme == .dark ? Color(.secondarySystemGroupedBackground) : .white
    }

    private var shareText: String {
        var text = "\(formula.title)\n\n\(formula.latex)"
        if !formula.formulaDescription.isEmpty { text += "\n\n\(formula.formulaDescription)" }
        if !formula.whatIsItFor.isEmpty { text += "\n\n\(formula.whatIsItFor)" }
        text += "\n\n— Formulary"
        return text
    }

    private func saveNote() {
        let trimmed = newNoteText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let note = UserNote(noteText: trimmed, formula: formula)
        modelContext.insert(note)
        try? modelContext.save()
        newNoteText = ""
        showingNoteEditor = false
        HapticFeedback.success()
    }

    private func loadRelatedFormulas() {
        guard !formula.relatedFormulaTitles.isEmpty else { return }
        let titles = formula.relatedFormulaTitles
        let descriptor = FetchDescriptor<Formula>()
        guard let all = try? modelContext.fetch(descriptor) else { return }
        relatedFormulas = titles.compactMap { t in all.first { $0.title == t } }
    }

    private func categoryIndex(for category: Category) -> Int? {
        let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.order)])
        guard let cats = try? modelContext.fetch(descriptor) else { return nil }
        return cats.firstIndex { $0.id == category.id }
    }

    private func parseVariables(_ raw: String) -> [ParsedVariable] {
        let separators = [",", ";", "\n"]
        var parts = [raw]
        for sep in separators { parts = parts.flatMap { $0.components(separatedBy: sep) } }
        let cleaned = parts.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }

        return cleaned.map { line in
            let delimiters: [String] = [" = ", "=", " : ", ":"]
            for delim in delimiters {
                if let range = line.range(of: delim) {
                    let symbol = String(line[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                    let rest = String(line[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                    var name = rest
                    var unit: String? = nil
                    if let open = rest.lastIndex(of: "("),
                       let close = rest.lastIndex(of: ")"), open < close {
                        unit = String(rest[rest.index(after: open)..<close]).trimmingCharacters(in: .whitespaces)
                        name = String(rest[..<open]).trimmingCharacters(in: .whitespaces)
                    }
                    return ParsedVariable(
                        symbol: symbol.isEmpty ? "?" : String(symbol.prefix(4)),
                        name: name.isEmpty ? rest : name,
                        unit: unit
                    )
                }
            }
            let words = line.split(separator: " ", maxSplits: 1)
            if words.count >= 2 {
                return ParsedVariable(symbol: String(words[0].prefix(4)), name: String(words[1]), unit: nil)
            }
            return ParsedVariable(symbol: "•", name: line, unit: nil)
        }
    }
}

// MARK: - Collapsible Card

struct CollapsibleCard<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    @Binding var isExpanded: Bool
    @ViewBuilder let content: () -> Content
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    SectionIcon(systemName: icon, color: color)
                    Text(title)
                        .font(.qCaption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                content()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(cardFill)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private var cardFill: Color {
        colorScheme == .dark ? Color(.secondarySystemGroupedBackground) : .white
    }
}

// MARK: - Supporting Components

struct ParsedVariable: Hashable {
    let symbol: String
    let name: String
    let unit: String?
}

struct SectionIcon: View {
    let systemName: String
    let color: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 24, height: 24)
            .background(color.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

struct TagPill: View {
    let tag: String

    var body: some View {
        Text(tag)
            .font(.qCaption2)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.appPrimary.opacity(0.1))
            .foregroundStyle(Color.appPrimary)
            .clipShape(Capsule())
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        layout(in: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: ProposedViewSize(width: bounds.width, height: bounds.height), subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(in proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}

struct NoteRow: View {
    let note: UserNote
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.noteText)
                .font(.qCaption)
                .foregroundStyle(.primary)

            HStack {
                Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.qCaption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption2)
                        .foregroundStyle(.red.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    let formula = Formula(
        title: "Quadratic Formula",
        latex: "x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}",
        formulaDescription: "Solves the general quadratic equation ax² + bx + c = 0 for x.",
        whatIsItFor: "Used in algebra to find roots of any quadratic equation.",
        variables: "a = leading coefficient, b = linear coefficient, c = constant term, x = roots",
        level: .highSchool,
        tags: ["quadratic", "roots", "polynomial"],
        relatedFormulaTitles: ["Discriminant"]
    )
    NavigationStack {
        FormulaDetailView(formula: formula)
    }
    .modelContainer(for: [Category.self, Subcategory.self, Formula.self, UserNote.self], inMemory: true)
}
