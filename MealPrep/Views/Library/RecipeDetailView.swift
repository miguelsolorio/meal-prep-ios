import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject private var store: RecipeStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image
                RecipeImageView(url: recipe.imageURL, cornerRadius: 12)
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .clipped()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 20) {
                    // Title & metadata
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 16) {
                            if !recipe.displayDuration.isEmpty {
                                Label(recipe.displayDuration, systemImage: "clock")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            if !recipe.servingsText.isEmpty {
                                Label(recipe.servingsText, systemImage: "person.2")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if !recipe.author.isEmpty {
                            Text("By \(recipe.author)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    // Ingredients
                    if !recipe.ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Ingredients")
                                .font(.title3)
                                .fontWeight(.semibold)

                            ForEach(recipe.ingredients, id: \.self) { ingredient in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundStyle(.secondary)
                                    Text(ingredient)
                                        .font(.body)
                                }
                            }
                        }
                    }

                    Divider()

                    // Instructions
                    if !recipe.instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Instructions")
                                .font(.title3)
                                .fontWeight(.semibold)

                            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(width: 28, height: 28)
                                        .background(Color.accentColor)
                                        .clipShape(Circle())

                                    Text(step)
                                        .font(.body)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }

                    // Open in Safari
                    Link(destination: recipe.sourceURL) {
                        Label("Open in Safari", systemImage: "safari")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !store.isSelected(recipe.id) {
                    Button {
                        store.addToShoppingList(recipe.id)
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
        }
    }
}
