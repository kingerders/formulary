import Foundation
import StoreKit

/// StoreKit 2 based purchase service for per-discipline premium content
///
/// Pricing:
/// - Individual discipline: $0.99 each
/// - All disciplines bundle: $9.99
@MainActor
class PurchaseService: ObservableObject {
    static let shared = PurchaseService()

    // MARK: - Developer Mode
    /// Always false in production. No developer bypass.
    static let isDeveloperMode: Bool = false

    // MARK: - Free Subcategories (partially free within a paid discipline)
    /// Only these subcategories are accessible without purchasing the parent discipline.
    static let freeSubcategories: [String: Set<String>] = [
        "Mathematics": ["Algebra"]
    ]

    // MARK: - Free Disciplines (always fully unlocked — currently none)
    static let freeDisciplines: Set<String> = []

    // MARK: - Product Identifiers
    static let allDisciplinesBundleID = "com.erders.formulary.discipline.all"

    /// Maps category names to StoreKit product IDs
    static let disciplineProductIDs: [String: String] = [
        "Mathematics": "com.erders.formulary.discipline.mathematics",
        "Physics": "com.erders.formulary.discipline.physics",
        "Chemistry": "com.erders.formulary.discipline.chemistry",
        "Geometry": "com.erders.formulary.discipline.geometry",
        "Environmental Engineering": "com.erders.formulary.discipline.environmental_engineering",
        "Geological Engineering": "com.erders.formulary.discipline.geological_engineering",
        "Chemical Engineering": "com.erders.formulary.discipline.chemical_engineering",
        "Mechanical Engineering": "com.erders.formulary.discipline.mechanical_engineering",
        "Electrical Engineering": "com.erders.formulary.discipline.electrical_engineering",
        "Civil Engineering": "com.erders.formulary.discipline.civil_engineering",
        "Geophysics": "com.erders.formulary.discipline.geophysics",
        "Geochemistry": "com.erders.formulary.discipline.geochemistry",
        "Biology & Biomedical Engineering": "com.erders.formulary.discipline.biology",
        "Computer Science": "com.erders.formulary.discipline.computer_science",
        "Meteorology & Atmospheric Science": "com.erders.formulary.discipline.meteorology",
        "Astronomy & Astrophysics": "com.erders.formulary.discipline.astronomy",
    ]

    // MARK: - Published State
    @Published var products: [Product] = []
    @Published var bundleProduct: Product?
    @Published var purchasedDisciplines: Set<String> = []   // Set of category names
    @Published var hasAllBundle: Bool = false
    @Published var purchaseError: String?

    /// Convenience: true if every discipline is unlocked (bundle or all individually purchased)
    var isPremium: Bool {
        if Self.isDeveloperMode { return true }
        if hasAllBundle { return true }
        let allNames = Set(Self.disciplineProductIDs.keys)
        return allNames.isSubset(of: purchasedDisciplines)
    }

    private var transactionListener: Task<Void, Error>?

    private init() {
        transactionListener = listenForTransactions()
        Task {
            await checkCurrentEntitlements()
            await loadProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Check Discipline Access

    /// Returns true if the given discipline (category name) is fully unlocked
    func isDisciplineUnlocked(_ categoryName: String) -> Bool {
        if Self.isDeveloperMode { return true }
        if Self.freeDisciplines.contains(categoryName) { return true }
        if hasAllBundle { return true }
        return purchasedDisciplines.contains(categoryName)
    }

    /// Returns true if a specific subcategory is accessible.
    /// A subcategory is accessible if:
    ///   - The parent discipline is unlocked, OR
    ///   - It is listed as a free subcategory for that discipline.
    func isSubcategoryUnlocked(_ subcategoryName: String, in categoryName: String) -> Bool {
        if isDisciplineUnlocked(categoryName) { return true }
        return Self.freeSubcategories[categoryName]?.contains(subcategoryName) ?? false
    }

    /// Returns the product for a given discipline name, nil if not loaded yet
    func product(for categoryName: String) -> Product? {
        guard let productID = Self.disciplineProductIDs[categoryName] else { return nil }
        return products.first { $0.id == productID }
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            var allIDs = Set(Self.disciplineProductIDs.values)
            allIDs.insert(Self.allDisciplinesBundleID)
            let loaded = try await Product.products(for: allIDs)
            // Separate bundle from individual products
            bundleProduct = loaded.first { $0.id == Self.allDisciplinesBundleID }
            products = loaded
                .filter { $0.id != Self.allDisciplinesBundleID }
                .sorted { $0.displayName < $1.displayName }
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await checkCurrentEntitlements()
                return true

            case .userCancelled:
                return false

            case .pending:
                purchaseError = "Purchase is pending approval."
                return false

            @unknown default:
                return false
            }
        } catch {
            purchaseError = error.localizedDescription
            return false
        }
    }

    /// Purchase a specific discipline by category name
    func purchaseDiscipline(_ categoryName: String) async -> Bool {
        guard let product = product(for: categoryName) else {
            purchaseError = "Product not available."
            return false
        }
        return await purchase(product)
    }

    /// Purchase the "All Disciplines" bundle
    func purchaseAllBundle() async -> Bool {
        guard let bundle = bundleProduct else {
            purchaseError = "Bundle product not available."
            return false
        }
        return await purchase(bundle)
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        try? await AppStore.sync()
        await checkCurrentEntitlements()
    }

    // MARK: - Check Entitlements

    func checkCurrentEntitlements() async {
        var disciplines: Set<String> = []
        var allBundle = false
        let reverseLookup = Dictionary(uniqueKeysWithValues: Self.disciplineProductIDs.map { ($1, $0) })

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productID == Self.allDisciplinesBundleID {
                    allBundle = true
                } else if let categoryName = reverseLookup[transaction.productID] {
                    disciplines.insert(categoryName)
                }
            }
        }

        purchasedDisciplines = disciplines
        hasAllBundle = allBundle
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    await transaction.finish()
                    await self.checkCurrentEntitlements()
                }
            }
        }
    }

    // MARK: - Verify Transaction

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
