import SwiftUI
import SwiftData

/// Home screen with educational design, Quicksand font, and modern category grid
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var purchaseService: PurchaseService
    @State private var viewModel = CategoryViewModel()
    @State private var animateCards = false
    @State private var selectedLockedCategory: Category?

    private var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 14), count: count)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                heroSection
                    .padding(.bottom, 22)

                statsRibbon
                    .padding(.horizontal, 16)
                    .padding(.bottom, 26)

                HStack {
                    Label("Disciplines", systemImage: "square.grid.2x2.fill")
                        .font(.qTitle3)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(viewModel.categories.count)")
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
                    ForEach(Array(viewModel.categories.enumerated()), id: \.element.id) { index, category in
                        let isUnlocked = purchaseService.isDisciplineUnlocked(category.name)
                        // Allow navigation if fully unlocked OR if it has partial free subcategories
                        let hasPartialAccess = PurchaseService.freeSubcategories[category.name] != nil
                        let canNavigate = isUnlocked || hasPartialAccess

                        if canNavigate {
                            NavigationLink(value: category) {
                                CategoryCardView(category: category, index: index)
                                    .opacity(animateCards ? 1 : 0)
                                    .offset(y: animateCards ? 0 : 20)
                                    .animation(
                                        .spring(response: 0.45, dampingFraction: 0.82)
                                        .delay(Double(index) * 0.03),
                                        value: animateCards
                                    )
                            }
                            .buttonStyle(CategoryButtonStyle())
                        } else {
                            Button {
                                selectedLockedCategory = category
                            } label: {
                                CategoryCardView(category: category, index: index)
                                    .opacity(animateCards ? 1 : 0)
                                    .offset(y: animateCards ? 0 : 20)
                                    .animation(
                                        .spring(response: 0.45, dampingFraction: 0.82)
                                        .delay(Double(index) * 0.03),
                                        value: animateCards
                                    )
                            }
                            .buttonStyle(CategoryButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: Category.self) { category in
            CategoryDetailView(category: category)
        }
        .navigationDestination(for: Formula.self) { formula in
            FormulaDetailView(formula: formula)
        }
        .sheet(item: $selectedLockedCategory) { category in
            DisciplinePurchaseView(categoryName: category.name)
        }
        .onAppear {
            viewModel.loadCategories(modelContext: modelContext)
            withAnimation(.easeOut(duration: 0.4)) {
                animateCards = true
            }
        }
    }

    // MARK: - Hero Section (educational design)

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Educational gradient — fills the full hero including behind status bar
            // (ScrollView ignoresSafeArea handles the safe area extension)
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.13, green: 0.15, blue: 0.32), location: 0),
                    .init(color: Color(red: 0.16, green: 0.28, blue: 0.45), location: 0.5),
                    .init(color: Color(red: 0.12, green: 0.38, blue: 0.42), location: 1),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                ZStack {
                    PatternOverlay()
                    FormulaSymbolsOverlay()
                }
            )

            HStack(spacing: 14) {
                // App logo
                Group {
                    if let uiImage = UIImage(named: "AppLogo") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                    } else {
                        // Fallback logo
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appPrimary, Color.appSecondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 52, height: 52)
                                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)

                            Text("𝑓")
                                .font(.system(size: 28, weight: .light, design: .serif))
                                .foregroundStyle(.white)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Formulary")
                        .font(.quicksand(22, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Your Science & Engineering Companion")
                        .font(.quicksand(12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)

                    Text("\(totalFormulaCount)+ formulas · \(viewModel.categories.count) disciplines")
                        .font(.quicksand(11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .frame(minHeight: 230)
    }

    // MARK: - Stats Ribbon

    private var statsRibbon: some View {
        HStack(spacing: 0) {
            StatPill(value: "\(viewModel.categories.count)", label: "Disciplines", icon: "square.grid.2x2.fill", color: .appPrimary)
            Spacer()
            Divider().frame(height: 28)
            Spacer()
            StatPill(value: "\(totalSubcategoryCount)", label: "Topics", icon: "folder.fill", color: .appSecondary)
            Spacer()
            Divider().frame(height: 28)
            Spacer()
            StatPill(value: "\(totalFormulaCount)+", label: "Formulas", icon: "function", color: .appAccent)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(.separator).opacity(0.15), lineWidth: 0.5)
        )
    }

    // MARK: - Data

    private var totalFormulaCount: Int {
        viewModel.categories.reduce(0) { $0 + $1.formulaCount }
    }

    private var totalSubcategoryCount: Int {
        viewModel.categories.reduce(0) { $0 + $1.subcategories.count }
    }

}

// MARK: - Button Style

struct CategoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Pattern Overlay (educational grid feel)

struct PatternOverlay: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let spacing: CGFloat = 30
                for x in stride(from: 0, through: geo.size.width, by: spacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                }
                for y in stride(from: 0, through: geo.size.height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(.white.opacity(0.04), lineWidth: 0.5)
        }
    }
}

// MARK: - Floating Formula Symbols

struct FormulaSymbolsOverlay: View {
    var body: some View {
        ZStack {
            Text("∫").font(.system(size: 30, design: .serif))
                .foregroundStyle(.white.opacity(0.07))
                .offset(x: -60, y: -40)
            Text("Σ").font(.system(size: 24, design: .serif))
                .foregroundStyle(.white.opacity(0.06))
                .offset(x: 90, y: 30)
            Text("∂").font(.system(size: 22, design: .serif))
                .foregroundStyle(.white.opacity(0.06))
                .offset(x: -30, y: 50)
            Text("π").font(.system(size: 26, design: .serif))
                .foregroundStyle(.white.opacity(0.05))
                .offset(x: 50, y: -20)
            Text("∇").font(.system(size: 20, design: .serif))
                .foregroundStyle(.white.opacity(0.05))
                .offset(x: -100, y: 10)
            Text("λ").font(.system(size: 22, design: .serif))
                .foregroundStyle(.white.opacity(0.04))
                .offset(x: 110, y: -50)
        }
    }
}

// MARK: - Featured Formula Card

struct FeaturedFormulaCard: View {
    let formula: Formula
    @Environment(\.colorScheme) private var colorScheme

    private var vizEntry: VisualizationEntry? {
        VisualizationRegistry.visualization(for: formula.title)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let entry = vizEntry {
                    Image(systemName: entry.type.icon)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(badgeColor.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                Spacer()
                Text("📊")
                    .font(.system(size: 11))
            }

            Text(formula.title)
                .font(.qCaption)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            LaTeXTextView(latex: formula.latex, fontSize: 11, color: .secondary)

            HStack(spacing: 6) {
                LevelBadgeView(level: formula.level)
                if let cat = formula.subcategory?.category {
                    Text(cat.icon)
                        .font(.system(size: 10))
                }
            }
        }
        .padding(12)
        .frame(width: 160, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(colorScheme == .dark ? Color(.secondarySystemGroupedBackground) : .white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(.separator).opacity(0.2), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    private var badgeColor: Color {
        guard let entry = vizEntry else { return .blue }
        switch entry.type {
        case .parameterGraph: return .blue
        case .geometric: return .orange
        case .process: return .green
        case .vectorField: return .purple
        }
    }
}

/// Small stat indicator
struct StatPill: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.qSubheadline)
                    .foregroundStyle(.primary)
                Text(label)
                    .font(.quicksand(9, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(for: [Category.self, Subcategory.self, Formula.self, UserNote.self], inMemory: true)
}
