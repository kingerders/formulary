import SwiftUI
import SwiftData

@main
struct FormularyApp: App {
    @StateObject private var purchaseService = PurchaseService.shared
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                Category.self,
                Subcategory.self,
                Formula.self,
                UserNote.self
            ])
            let config = ModelConfiguration(schema: schema)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Schema migration failed — delete the store and recreate
            print("⚠️ ModelContainer failed, recreating store: \(error)")
            let config = ModelConfiguration()
            // Remove old store file so a fresh one is created
            if let url = config.url as URL? {
                let fm = FileManager.default
                for suffix in ["", "-wal", "-shm"] {
                    let fileURL = url.deletingPathExtension().appendingPathExtension("store\(suffix)")
                    try? fm.removeItem(at: fileURL)
                }
            }
            // Reset version so data re-seeds
            UserDefaults.standard.removeObject(forKey: "formulary_data_version")
            do {
                let schema = Schema([
                    Category.self,
                    Subcategory.self,
                    Formula.self,
                    UserNote.self
                ])
                let freshConfig = ModelConfiguration(schema: schema)
                modelContainer = try ModelContainer(for: schema, configurations: [freshConfig])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(purchaseService)
        }
        .modelContainer(modelContainer)
    }
}
