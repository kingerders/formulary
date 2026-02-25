import Foundation
import SwiftData

/// Codable structures for parsing seed data JSON
struct SeedData: Codable {
    let categories: [SeedCategory]
}

struct SeedCategory: Codable {
    let name: String
    let icon: String
    let subcategories: [SeedSubcategory]
}

struct SeedSubcategory: Codable {
    let name: String
    let formulas: [SeedFormula]
}

struct SeedFormula: Codable {
    let title: String
    let latex: String
    let description: String
    let whatIsItFor: String?
    let variables: String
    let level: String
    let tags: [String]
    let isPremium: Bool?
    let imageName: String?
    let relatedFormulaTitles: [String]?
}

/// Service responsible for loading, parsing, and seeding formula data
@MainActor
class DataService {
    static let shared = DataService()

    /// Bump this version whenever the seed data or model schema changes.
    /// The app will automatically wipe and re-seed on next launch.
    private static let currentDataVersion = 29
    private static let dataVersionKey = "formulary_data_version"

    private init() {}

    /// Check if data has already been seeded with the current version
    func isDataSeeded(modelContext: ModelContext) -> Bool {
        let storedVersion = UserDefaults.standard.integer(forKey: Self.dataVersionKey)
        guard storedVersion >= Self.currentDataVersion else { return false }
        let descriptor = FetchDescriptor<Category>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        return count > 0
    }

    /// Seed or update data from bundled JSON file using upsert logic —
    /// existing disciplines and subcategories are updated in-place;
    /// only missing formulas are inserted. No duplicates are created.
    func seedDataIfNeeded(modelContext: ModelContext) {
        guard !isDataSeeded(modelContext: modelContext) else { return }

        guard let url = Bundle.main.url(forResource: "formulary_data", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("⚠️ Could not load formulary_data.json")
            return
        }

        do {
            let decoder = JSONDecoder()
            let seedData = try decoder.decode(SeedData.self, from: data)
            let supplementalImageMap = loadSupplementalImageMap()
            upsertSeedData(seedData, supplementalImageMap: supplementalImageMap, modelContext: modelContext)
            try modelContext.save()
            UserDefaults.standard.set(Self.currentDataVersion, forKey: Self.dataVersionKey)
            print("✅ Successfully seeded/updated \(seedData.categories.count) categories")
        } catch {
            print("❌ Error seeding data: \(error)")
        }
    }

    /// Upsert seed data: update existing disciplines/subcategories in-place,
    /// add only new formulas. Never duplicates a discipline or subcategory.
    private func upsertSeedData(
        _ seedData: SeedData,
        supplementalImageMap: [String: String],
        modelContext: ModelContext
    ) {
        // ── Step 1: Remove pre-existing duplicate Categories (keep one per name) ──
        let allCategories = (try? modelContext.fetch(FetchDescriptor<Category>())) ?? []
        var seenCategoryNames = Set<String>()
        for cat in allCategories {
            if seenCategoryNames.contains(cat.name) {
                modelContext.delete(cat)
            } else {
                seenCategoryNames.insert(cat.name)
            }
        }

        // ── Step 2: Remove pre-existing duplicate Subcategories (keep one per name+category) ──
        let allSubcategories = (try? modelContext.fetch(FetchDescriptor<Subcategory>())) ?? []
        var seenSubKeys = Set<String>()
        for sub in allSubcategories {
            let key = "\(sub.category?.name ?? "")|\(sub.name)"
            if seenSubKeys.contains(key) {
                modelContext.delete(sub)
            } else {
                seenSubKeys.insert(key)
            }
        }

        // ── Step 3: Build lookup maps from the now-deduplicated store ──
        let existingCategories = (try? modelContext.fetch(FetchDescriptor<Category>())) ?? []
        var categoryByName: [String: Category] = [:]
        for cat in existingCategories { categoryByName[cat.name] = cat }

        let existingSubcategories = (try? modelContext.fetch(FetchDescriptor<Subcategory>())) ?? []
        var subcategoryByKey: [String: Subcategory] = [:]
        for sub in existingSubcategories {
            let key = "\(sub.category?.name ?? "")|\(sub.name)"
            subcategoryByKey[key] = sub
        }

        let existingFormulas = (try? modelContext.fetch(FetchDescriptor<Formula>())) ?? []
        var formulaByTitle: [String: Formula] = [:]
        for formula in existingFormulas { formulaByTitle[formula.title] = formula }

        for (catIndex, seedCategory) in seedData.categories.enumerated() {
            // Upsert category — never insert a duplicate discipline
            let category: Category
            if let existing = categoryByName[seedCategory.name] {
                existing.icon = seedCategory.icon
                existing.order = catIndex
                category = existing
            } else {
                let newCategory = Category(
                    name: seedCategory.name,
                    icon: seedCategory.icon,
                    order: catIndex,
                    isPremium: false
                )
                modelContext.insert(newCategory)
                categoryByName[seedCategory.name] = newCategory
                category = newCategory
            }

            for (subIndex, seedSubcategory) in seedCategory.subcategories.enumerated() {
                let subKey = "\(seedCategory.name)|\(seedSubcategory.name)"

                // Upsert subcategory — never insert a duplicate subcategory
                let subcategory: Subcategory
                if let existing = subcategoryByKey[subKey] {
                    existing.order = subIndex
                    subcategory = existing
                } else {
                    let newSubcategory = Subcategory(
                        name: seedSubcategory.name,
                        order: subIndex,
                        category: category
                    )
                    modelContext.insert(newSubcategory)
                    subcategoryByKey[subKey] = newSubcategory
                    subcategory = newSubcategory
                }

                for (formulaIndex, seedFormula) in seedSubcategory.formulas.enumerated() {
                    let level = FormulaLevel(rawValue: seedFormula.level) ?? .undergraduate
                    let seedImageName = seedFormula.imageName ?? ""
                    let resolvedImageName = seedImageName.isEmpty
                        ? (supplementalImageMap[seedFormula.title] ?? "")
                        : seedImageName

                    if let existing = formulaByTitle[seedFormula.title] {
                        // Update all fields of the existing formula in-place
                        existing.latex = seedFormula.latex
                        existing.formulaDescription = seedFormula.description
                        existing.whatIsItFor = seedFormula.whatIsItFor ?? ""
                        existing.variables = seedFormula.variables
                        existing.order = formulaIndex
                        existing.level = level
                        existing.isPremium = seedFormula.isPremium ?? false
                        existing.tags = seedFormula.tags
                        existing.imageName = resolvedImageName
                        existing.relatedFormulaTitles = seedFormula.relatedFormulaTitles ?? []
                        existing.subcategory = subcategory
                    } else {
                        // Insert only truly new formulas
                        let formula = Formula(
                            title: seedFormula.title,
                            latex: seedFormula.latex,
                            formulaDescription: seedFormula.description,
                            whatIsItFor: seedFormula.whatIsItFor ?? "",
                            variables: seedFormula.variables,
                            order: formulaIndex,
                            level: level,
                            isFavorite: false,
                            isPremium: seedFormula.isPremium ?? false,
                            tags: seedFormula.tags,
                            imageName: resolvedImageName,
                            relatedFormulaTitles: seedFormula.relatedFormulaTitles ?? [],
                            subcategory: subcategory
                        )
                        modelContext.insert(formula)
                        formulaByTitle[seedFormula.title] = formula
                    }
                }
            }
        }
    }

    private func loadSupplementalImageMap() -> [String: String] {
        let mapFileNames = [
            "math_diagram_map",
            "physics_diagram_map",
            "chemistry_diagram_map",
            "geometry_diagram_map",
            "mechanical_diagram_map",
            "electrical_diagram_map",
            "chem_eng_diagram_map",
            "geophys_diagram_map",
            "astro_diagram_map",
            "environ_diagram_map",
            "geological_diagram_map",
            "civil_diagram_map",
            "geochem_diagram_map",
            "biology_diagram_map",
            "cs_diagram_map",
            "meteo_diagram_map"
        ]

        var merged: [String: String] = [:]

        for fileName in mapFileNames {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let mapping = root["mapping"] as? [String: String] else {
                continue
            }

            for (title, imageName) in mapping {
                merged[title] = imageName
            }
        }

        return merged
    }

    /// Reset all data (for development/debugging)
    func resetAllData(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: UserNote.self)
            try modelContext.delete(model: Formula.self)
            try modelContext.delete(model: Subcategory.self)
            try modelContext.delete(model: Category.self)
            try modelContext.save()
            print("🗑️ All data reset")
        } catch {
            print("❌ Error resetting data: \(error)")
        }
    }
}
