import SwiftUI

/// Professional category card with gradient, icon, name, and formula count
struct CategoryCardView: View {
    let category: Category
    let index: Int
    @EnvironmentObject private var purchaseService: PurchaseService

    private var isUnlocked: Bool {
        purchaseService.isDisciplineUnlocked(category.name)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title at top + optional lock badge
            HStack(alignment: .top, spacing: 6) {
                Text(category.name)
                    .font(.quicksand(17, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 4)

                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(6)
                        .background(.white.opacity(0.15))
                        .clipShape(Circle())
                }
            }

            Spacer(minLength: 8)

            // Stats at bottom
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text("\(category.formulaCount)")
                        .fontWeight(.bold)
                    Text("formulas")
                }
                .font(.qCaption2)
                .foregroundStyle(.white.opacity(0.8))

                Text("\(category.subcategories.count) topics")
                    .font(.quicksand(9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(Color.categoryGradient(for: index))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(
            color: Color.categoryGradientColors(for: index).first?.opacity(0.3) ?? .clear,
            radius: 10, x: 0, y: 6
        )
        .overlay(
            // Dim overlay for locked disciplines
            !isUnlocked ?
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.black.opacity(0.2))
            : nil
        )
    }
}

#Preview {
    let category = Category(name: "Mathematics", icon: "📐", order: 0)
    CategoryCardView(category: category, index: 0)
        .frame(width: 170)
        .padding()
}
