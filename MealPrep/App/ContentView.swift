import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: RecipeStore

    var body: some View {
        TabView {
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }

            ManageView()
                .tabItem {
                    Label("Manage", systemImage: "checklist")
                }

            PlanningView()
                .tabItem {
                    Label("Planning", systemImage: "calendar")
                }

            ShoppingListView()
                .tabItem {
                    Label("Shopping List", systemImage: "cart")
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
