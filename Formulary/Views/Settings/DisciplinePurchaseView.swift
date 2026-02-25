import SwiftUI
import StoreKit

/// Purchase sheet for unlocking a single discipline or the full bundle
struct DisciplinePurchaseView: View {
    let categoryName: String
    @EnvironmentObject private var purchaseService: PurchaseService
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 14) {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.appPrimary, Color.appAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("Unlock \(categoryName)")
                            .font(.qTitle2)
                            .multilineTextAlignment(.center)

                        Text("Get full access to all formulas, variables, and visualizations in this discipline.")
                            .font(.qSubheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 24)

                    // Benefits
                    VStack(alignment: .leading, spacing: 14) {
                        BenefitRow(icon: "function", title: "All Formulas", description: "Complete formula collection")
                        BenefitRow(icon: "text.book.closed", title: "Variables & Definitions", description: "Detailed explanations")
                        BenefitRow(icon: "arrow.down.circle", title: "Offline Access", description: "No internet needed")
                        BenefitRow(icon: "sparkles", title: "Future Updates", description: "New formulas added regularly")
                    }
                    .padding(.horizontal, 24)

                    // Purchase Options
                    VStack(spacing: 14) {
                        // Individual discipline purchase
                        if let product = purchaseService.product(for: categoryName) {
                            PurchaseButton(
                                title: "Unlock \(categoryName)",
                                subtitle: "One-time purchase",
                                price: product.displayPrice,
                                isPrimary: true,
                                isLoading: isPurchasing
                            ) {
                                await performPurchase {
                                    await purchaseService.purchaseDiscipline(categoryName)
                                }
                            }
                        }

                        // Bundle purchase
                        if let bundle = purchaseService.bundleProduct {
                            PurchaseButton(
                                title: "Unlock All Disciplines",
                                subtitle: "Best value — all 16 disciplines",
                                price: bundle.displayPrice,
                                isPrimary: false,
                                isLoading: isPurchasing
                            ) {
                                await performPurchase {
                                    await purchaseService.purchaseAllBundle()
                                }
                            }
                        }

                        // Fallback when products haven't loaded
                        if purchaseService.products.isEmpty {
                            VStack(spacing: 8) {
                                ProgressView()
                                Text("Loading prices…")
                                    .font(.qCaption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                        }

                        // Restore purchases
                        Button {
                            Task {
                                await purchaseService.restorePurchases()
                                if purchaseService.isDisciplineUnlocked(categoryName) {
                                    dismiss()
                                }
                            }
                        } label: {
                            Text("Restore Purchases")
                                .font(.qCaption)
                                .foregroundStyle(Color.appPrimary)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)

                    // Error message
                    if let error = purchaseService.purchaseError {
                        Text(error)
                            .font(.qCaption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func performPurchase(_ action: @escaping () async -> Bool) async {
        isPurchasing = true
        let success = await action()
        isPurchasing = false
        if success {
            dismiss()
        }
    }
}

// MARK: - Purchase Button

struct PurchaseButton: View {
    let title: String
    let subtitle: String
    let price: String
    let isPrimary: Bool
    let isLoading: Bool
    let action: () async -> Void

    var body: some View {
        Button {
            Task { await action() }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.qSubheadline)
                        .fontWeight(.semibold)
                    Text(subtitle)
                        .font(.qCaption2)
                        .foregroundStyle(isPrimary ? .white.opacity(0.8) : .secondary)
                }

                Spacer()

                if isLoading {
                    ProgressView()
                        .tint(isPrimary ? .white : Color.appPrimary)
                } else {
                    Text(price)
                        .font(.qSubheadline)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                isPrimary
                    ? AnyShapeStyle(
                        LinearGradient(
                            colors: [Color.appPrimary, Color.appPrimary.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    : AnyShapeStyle(Color(.tertiarySystemFill))
            )
            .foregroundStyle(isPrimary ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

// MARK: - All Disciplines Purchase View (for Settings)

/// Full purchase view showing all discipline options and the bundle
struct AllDisciplinesPurchaseView: View {
    @EnvironmentObject private var purchaseService: PurchaseService
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.appAccent, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("Formulary Premium")
                            .font(.qTitle)

                        Text("Unlock disciplines individually or get the best deal with the full bundle.")
                            .font(.qSubheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 20)

                    // Bundle option (highlighted)
                    if let bundle = purchaseService.bundleProduct {
                        VStack(spacing: 8) {
                            Text("BEST VALUE")
                                .font(.quicksand(10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.appAccent)
                                .clipShape(Capsule())

                            PurchaseButton(
                                title: "All 16 Disciplines",
                                subtitle: "One purchase, everything unlocked",
                                price: bundle.displayPrice,
                                isPrimary: true,
                                isLoading: isPurchasing
                            ) {
                                isPurchasing = true
                                let success = await purchaseService.purchaseAllBundle()
                                isPurchasing = false
                                if success { dismiss() }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Individual disciplines
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Or unlock individually")
                            .font(.qCaption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)

                        ForEach(purchaseService.products, id: \.id) { product in
                            let categoryName = disciplineName(for: product.id)
                            let isOwned = purchaseService.isDisciplineUnlocked(categoryName)
                            let isFree = false // No disciplines are fully free anymore

                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(categoryName)
                                        .font(.qSubheadline)
                                        .fontWeight(.medium)
                                }

                                Spacer()

                                if isFree {
                                    Text("Free")
                                        .font(.qCaption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.green)
                                } else if isOwned {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else {
                                    Button {
                                        Task {
                                            isPurchasing = true
                                            _ = await purchaseService.purchase(product)
                                            isPurchasing = false
                                        }
                                    } label: {
                                        Text(product.displayPrice)
                                            .font(.qCaption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(Color.appPrimary)
                                            .foregroundStyle(.white)
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(isPurchasing)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 16)
                        }
                    }

                    // Restore
                    Button {
                        Task { await purchaseService.restorePurchases() }
                    } label: {
                        Text("Restore Purchases")
                            .font(.qCaption)
                            .foregroundStyle(Color.appPrimary)
                    }
                    .padding(.top, 8)

                    if let error = purchaseService.purchaseError {
                        Text(error)
                            .font(.qCaption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    /// Reverse-lookup: product ID → category name
    private func disciplineName(for productID: String) -> String {
        for (name, id) in PurchaseService.disciplineProductIDs where id == productID {
            return name
        }
        return productID
    }
}

#Preview("Discipline Purchase") {
    DisciplinePurchaseView(categoryName: "Mechanical Engineering")
        .environmentObject(PurchaseService.shared)
}

#Preview("All Disciplines") {
    AllDisciplinesPurchaseView()
        .environmentObject(PurchaseService.shared)
}

// MARK: - Benefit Row

/// A row showing a premium benefit
struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.qSubheadline)
                Text(description)
                    .font(.qCaption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
