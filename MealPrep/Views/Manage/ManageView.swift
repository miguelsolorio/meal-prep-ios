import SwiftUI

struct ManageView: View {
    @EnvironmentObject private var store: RecipeStore

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

                                Spacer(minLength: 0)

                                Button {
                                    store.removeFromShoppingList(recipe.id)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Manage")
        }
    }
}
