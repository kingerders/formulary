import SwiftUI
import SwiftData

/// Settings screen with theme, premium status, about, and feedback
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var purchaseService: PurchaseService
    @AppStorage("appTheme") private var appTheme: String = "system"
    @State private var showResetAlert = false
    @State private var showPremiumSheet = false

    var body: some View {
        List {
            // Appearance
            Section("Appearance") {
                Picker("Theme", selection: $appTheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.menu)
            }

            // Premium
            Section("Premium") {
                HStack {
                    Label("Status", systemImage: "crown.fill")
                    Spacer()
                    if purchaseService.isPremium {
                        Text("All Unlocked")
                            .foregroundStyle(Color.appSecondary)
                            .fontWeight(.medium)
                    } else {
                        let unlockedCount = purchaseService.purchasedDisciplines.count
                        Text("\(unlockedCount)/16 Disciplines")
                            .foregroundStyle(Color.secondary)
                            .fontWeight(.medium)
                    }
                }

                if !purchaseService.isPremium {
                    // Prominent bundle purchase button
                    Button {
                        showPremiumSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Get All 16 Disciplines")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                if let bundle = purchaseService.bundleProduct {
                                    Text(bundle.displayPrice + " · One-time purchase")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("$9.99 · One-time purchase")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button {
                        showPremiumSheet = true
                    } label: {
                        Label("Unlock Individual Disciplines", systemImage: "sparkles")
                            .foregroundStyle(Color.appPrimary)
                    }

                    Button {
                        Task {
                            await purchaseService.restorePurchases()
                        }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                }
            }

            // Data
            Section("Data") {
                HStack {
                    Label("Categories", systemImage: "folder")
                    Spacer()
                    Text(categoryCount)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Total Formulas", systemImage: "function")
                    Spacer()
                    Text(formulaCount)
                        .foregroundStyle(.secondary)
                }

                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Label("Reset All Data", systemImage: "trash")
                        .foregroundStyle(.red)
                }
            }

            // About
            Section("About") {
                HStack {
                    Label("Version", systemImage: "info.circle")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }

                Link(destination: URL(string: "mailto:feedback@formularyapp.com")!) {
                    Label("Send Feedback", systemImage: "envelope")
                }

                Link(destination: URL(string: "https://github.com/kingerders/formulary/blob/main/PRIVACY_POLICY.md")!) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
            }
        }
        .navigationTitle("Settings")
        .alert("Reset All Data", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                DataService.shared.resetAllData(modelContext: modelContext)
                DataService.shared.seedDataIfNeeded(modelContext: modelContext)
            }
        } message: {
            Text("This will reset all formulas, favorites, and notes. The default formula data will be reloaded.")
        }
        .sheet(isPresented: $showPremiumSheet) {
            AllDisciplinesPurchaseView()
                .environmentObject(purchaseService)
        }
    }

    private var categoryCount: String {
        let descriptor = FetchDescriptor<Category>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        return "\(count)"
    }

    private var formulaCount: String {
        let descriptor = FetchDescriptor<Formula>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        return "\(count)"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(PurchaseService.shared)
    .modelContainer(for: [Category.self, Subcategory.self, Formula.self, UserNote.self], inMemory: true)
}
