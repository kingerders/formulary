import SwiftUI
import SwiftData

/// Main tab-based navigation structure
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("appTheme") private var appTheme: String = "system"

    private var preferredColorScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }

            NavigationStack {
                NotesView()
            }
            .tabItem {
                Label("Notes", systemImage: "note.text")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(Color.appPrimary)
        .preferredColorScheme(preferredColorScheme)
        .onAppear {
            DataService.shared.seedDataIfNeeded(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Category.self, Subcategory.self, Formula.self, UserNote.self], inMemory: true)
}
