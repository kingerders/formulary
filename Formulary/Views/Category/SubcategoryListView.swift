import SwiftUI

/// Professional expandable section showing a subcategory and its formulas
struct SubcategoryListView: View {
    let subcategory: Subcategory
    let isExpanded: Bool
    let onToggle: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Header button
            Button(action: onToggle) {
                HStack(spacing: 14) {
                    // Section icon
                    Image(systemName: "folder.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.appPrimary.opacity(isExpanded ? 1.0 : 0.6).gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(subcategory.name)
                            .font(.qSubheadline)
                            .foregroundStyle(.primary)

                        Text("\(subcategory.formulas.count) formulas")
                            .font(.qCaption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            // Expanded content
            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)

                VStack(spacing: 0) {
                    ForEach(subcategory.sortedFormulas) { formula in
                        NavigationLink(value: formula) {
                            FormulaCardView(formula: formula)
                        }
                        .buttonStyle(.plain)

                        if formula.id != subcategory.sortedFormulas.last?.id {
                            Divider()
                                .padding(.leading, 46)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colorScheme == .dark ? Color(.secondarySystemGroupedBackground) : .white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    let subcategory = Subcategory(name: "Algebra", order: 0)
    SubcategoryListView(subcategory: subcategory, isExpanded: true, onToggle: {})
        .padding()
}
