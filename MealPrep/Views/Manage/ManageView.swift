import SwiftUI

struct ManageView: View {
    @EnvironmentObject private var store: RecipeStore
    @State private var showingImport = false

    private var selectedRecipes: [Recipe] {
        store.recipes.filter { store.isSelected($0.id) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if selectedRecipes.isEmpty {
                    EmptyStateView(
                        systemImage: "checklist",
                        title: "No Recipes Added",
                        subtitle: "Tap + to import a recipe, or add one from the Library."
                    )
                } else {
                    List {
                        ForEach(selectedRecipes) { recipe in
                            NavigationLink {
                                RecipeDetailView(recipe: recipe)
                            } label: {
                                recipeRow(recipe)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.removeFromShoppingList(recipe.id)
                                } label: {
                                    Label("Remove", systemImage: "minus.circle")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingImport = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingImport) {
                ImportView()
            }
        }
    }

    private func recipeRow(_ recipe: Recipe) -> some View {
        HStack(spacing: 12) {
            RecipeImageView(url: recipe.imageURL, cornerRadius: 8)
                .frame(width: 56, height: 56)
                .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    if !recipe.displayDuration.isEmpty {
                        Label(recipe.displayDuration, systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if !recipe.author.isEmpty {
                        Text("· \(recipe.author)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
