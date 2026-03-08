import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var store: RecipeStore
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var showingFilter = false
    @State private var showingImport = false
    @State private var recipeToDelete: Recipe?
    @State private var showingDeleteConfirmation = false

    private var columns: [GridItem] {
        if sizeClass == .regular {
            [.init(.flexible()), .init(.flexible())]
        } else {
            [.init(.flexible())]
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.filteredRecipes.isEmpty {
                    EmptyStateView(
                        systemImage: "books.vertical",
                        title: store.recipes.isEmpty ? "No Recipes Yet" : "No Results",
                        subtitle: store.recipes.isEmpty
                            ? "Tap + to add your first recipe."
                            : "Try adjusting your search or filters."
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(store.filteredRecipes) { recipe in
                                NavigationLink {
                                    RecipeDetailView(recipe: recipe)
                                } label: {
                                    RecipeGridItemView(
                                        recipe: recipe,
                                        isSelected: store.isSelected(recipe.id),
                                        onAdd: { store.addToShoppingList(recipe.id) }
                                    )
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    deleteButton(for: recipe)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Library")
            .searchable(text: $store.searchText, prompt: "Search recipes")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingFilter = true
                    } label: {
                        Image(systemName: store.filterOptions.isDefault ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingImport = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingFilter) {
                FilterSortView(options: $store.filterOptions)
            }
            .sheet(isPresented: $showingImport) {
                ImportView()
            }
            .confirmationDialog(
                "Delete Recipe",
                isPresented: $showingDeleteConfirmation,
                presenting: recipeToDelete
            ) { recipe in
                Button("Delete \"\(recipe.name)\"", role: .destructive) {
                    store.deleteRecipe(recipe)
                }
                Button("Cancel", role: .cancel) {}
            } message: { recipe in
                Text("This will permanently remove \"\(recipe.name)\" from your library.")
            }
        }
    }

    @ViewBuilder
    private func deleteButton(for recipe: Recipe) -> some View {
        Button(role: .destructive) {
            recipeToDelete = recipe
            showingDeleteConfirmation = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
