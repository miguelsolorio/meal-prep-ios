import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: RecipeStore

    var body: some View {
        TabView {
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }

            PlanningView()
                .tabItem {
                    Label("Planning", systemImage: "calendar")
                }

            ShoppingListView()
                .tabItem {
                    Label("Shopping List", systemImage: "cart")
                }

            ManageView()
                .tabItem {
                    Label("Manage", systemImage: "wrench.and.screwdriver")
                }
        }
        .alert("Couldn't Import Recipe", isPresented: .init(
            get: { store.shareImportError != nil },
            set: { if !$0 { store.shareImportError = nil } }
        )) {
            Button("OK", role: .cancel) { store.shareImportError = nil }
        } message: {
            if let error = store.shareImportError {
                Text(error)
            }
        }
    }
}
