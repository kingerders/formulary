import SwiftUI
import SwiftData

/// Professional detail view for a category with subcategories displayed as a 2-column grid
struct CategoryDetailView: View {
    let category: Category
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var purchaseService: PurchaseService
    @State private var showPurchaseSheet = false

    private var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 14), count: count)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Gradient hero header
                categoryHero
                    .padding(.bottom, 18)

                // Subcategory grid (2 blocks per row, like disciplines on home page)
                HStack {
                    Label("Topics", systemImage: "folder.fill")
                        .font(.qTitle3)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(category.sortedSubcategories.count)")
                        .font(.qCaption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.appPrimary)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(Array(category.sortedSubcategories.enumerated()), id: \.element.id) { index, subcategory in
                        let isUnlocked = purchaseService.isSubcategoryUnlocked(subcategory.name, in: category.name)
                        if isUnlocked {
                            NavigationLink(value: subcategory) {
                                SubcategoryCardView(
                                    subcategory: subcategory,
                                    index: index,
                                    categoryIndex: categoryIndex ?? 0,
                                    isLocked: false
                                )
                            }
                            .buttonStyle(SubcategoryButtonStyle())
                        } else {
                            Button {
                                showPurchaseSheet = true
                            } label: {
                                SubcategoryCardView(
                                    subcategory: subcategory,
                                    index: index,
                                    categoryIndex: categoryIndex ?? 0,
                                    isLocked: true
                                )
                            }
                            .buttonStyle(SubcategoryButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(for: Subcategory.self) { subcategory in
            FormulaListView(subcategory: subcategory)
        }
        .navigationDestination(for: Formula.self) { formula in
            FormulaDetailView(formula: formula)
        }
        .sheet(isPresented: $showPurchaseSheet) {
            DisciplinePurchaseView(categoryName: category.name)
        }
    }

    // MARK: - Hero Header

    private var categoryHero: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient fills entire hero block including behind nav bar & status bar.
            // ScrollView.ignoresSafeArea(edges: .top) makes this work end-to-end.
            if let index = categoryIndex {
                LinearGradient(
                    colors: Color.categoryGradientColors(for: index),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            // Content sits at the bottom of the hero
            VStack(alignment: .leading, spacing: 6) {
                Text(category.name)
                    .font(.qTitle2)
                    .foregroundStyle(.white)

                HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 10))
                        Text("\(category.sortedSubcategories.count) topics")
                            .font(.qCaption)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "function")
                            .font(.system(size: 10))
                        Text("\(category.formulaCount) formulas")
                            .font(.qCaption)
                    }
                }
                .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .frame(height: 260)
    }

    private var categoryIndex: Int? {
        let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.order)])
        guard let categories = try? modelContext.fetch(descriptor) else { return nil }
        return categories.firstIndex { $0.id == category.id }
    }
}

// MARK: - Subcategory Card (grid block style, like CategoryCardView)

struct SubcategoryCardView: View {
    let subcategory: Subcategory
    let index: Int
    let categoryIndex: Int
    var isLocked: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title at top with larger font
            Text(subcategory.name)
                .font(.quicksand(16, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)

            // Formula count at bottom
            HStack(spacing: 4) {
                Text("\(subcategory.formulas.count)")
                    .fontWeight(.bold)
                Text("formulas")
            }
            .font(.qCaption2)
            .foregroundStyle(.white.opacity(0.8))
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        .background(subcategoryGradient)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            isLocked ?
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.black.opacity(0.22))
            : nil
        )
        .overlay(alignment: .topTrailing) {
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(6)
                    .background(.white.opacity(0.15))
                    .clipShape(Circle())
                    .padding(10)
            }
        }
        .shadow(
            color: Color.categoryGradientColors(for: categoryIndex).first?.opacity(0.2) ?? .clear,
            radius: 8, x: 0, y: 4
        )
    }

    private var subcategoryGradient: some View {
        let baseColors = Color.categoryGradientColors(for: categoryIndex)
        let adjustment = Double(index) * 0.08
        return LinearGradient(
            colors: baseColors.map { $0.opacity(1.0 - adjustment) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Button Style

struct SubcategoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    let category = Category(name: "Mathematics", icon: "📐", order: 0)
    NavigationStack {
        CategoryDetailView(category: category)
    }
    .modelContainer(for: [Category.self, Subcategory.self, Formula.self, UserNote.self], inMemory: true)
}
