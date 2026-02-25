import SwiftUI

/// Professional compact card showing a formula with LaTeX preview, level badge, and favorite toggle
struct FormulaCardView: View {
    let formula: Formula
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 14) {
            // Color accent strip
            RoundedRectangle(cornerRadius: 2)
                .fill(levelColor.gradient)
                .frame(width: 4, height: 56)

            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    Text(formula.title)
                        .font(.qSubheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Spacer(minLength: 4)

                    LevelBadgeView(level: formula.level)
                }

                if !formula.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(formula.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 9, weight: .medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.appPrimary.opacity(0.08))
                                .foregroundStyle(Color.appPrimary.opacity(0.8))
                                .clipShape(Capsule())
                        }
                        if formula.tags.count > 3 {
                            Text("+\(formula.tags.count - 3)")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }

            // Favorite button
            Button {
                withAnimation(.spring(response: 0.3)) {
                    formula.isFavorite.toggle()
                    try? modelContext.save()
                    HapticFeedback.selection()
                }
            } label: {
                Image(systemName: formula.isFavorite ? "heart.fill" : "heart")
                    .font(.body)
                    .foregroundStyle(formula.isFavorite ? Color.red : Color.secondary.opacity(0.3))
                    .symbolEffect(.bounce, value: formula.isFavorite)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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
    let formula = Formula(
        title: "Quadratic Formula",
        latex: "x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}",
        formulaDescription: "Solves ax² + bx + c = 0 for x.",
        variables: "a, b, c = coefficients; x = roots",
        level: .highSchool,
        tags: ["quadratic", "roots", "polynomial"]
    )
    FormulaCardView(formula: formula)
        .padding()
}
