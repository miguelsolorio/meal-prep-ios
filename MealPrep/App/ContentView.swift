import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }

            ShoppingListView()
                .tabItem {
                    Label("Shopping List", systemImage: "cart")
                }

        }
    }
}
