import SwiftUI

struct ManageRecipesView: View {
    @EnvironmentObject private var store: RecipeStore
    @Environment(\.dismiss) private var dismiss

    private var selectedRecipes: [Recipe] {
        store.recipes.filter { store.isSelected($0.id) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if selectedRecipes.isEmpty {
                    EmptyStateView(
                        systemImage: "cart",
                        title: "No Recipes",
                        subtitle: "Add recipes from the Library to build your shopping list."
                    )
                } else {
                    List {
                        ForEach(selectedRecipes) { recipe in
                            HStack(spacing: 12) {
                                RecipeImageView(url: recipe.imageURL, cornerRadius: 6)
                                    .frame(width: 44, height: 44)
                                    .clipped()

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recipe.name)
                                        .font(.headline)
                                        .lineLimit(2)

                                    if !recipe.author.isEmpty {
                                        Text(recipe.author)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer(minLength: 0)

                                Button {
                                    store.removeFromShoppingList(recipe.id)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(Color.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
