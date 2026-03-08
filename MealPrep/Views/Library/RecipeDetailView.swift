import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject private var store: RecipeStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Full-bleed hero image
                RecipeImageView(url: recipe.imageURL, cornerRadius: 0)
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .clipped()

                VStack(alignment: .leading, spacing: 24) {

                    // Title & metadata
                    VStack(alignment: .leading, spacing: 10) {
                        Text(recipe.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 8) {
                            if !recipe.displayDuration.isEmpty {
                                metaChip(icon: "clock", text: recipe.displayDuration)
                            }
                            if !recipe.servingsText.isEmpty {
                                metaChip(icon: "person.2", text: recipe.servingsText)
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
                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader("Ingredients")

                            ForEach(recipe.ingredients, id: \.self) { ingredient in
                                HStack(alignment: .top, spacing: 10) {
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 7)
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
                            sectionHeader("Instructions")

                            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 14) {
                                    Text("\(index + 1)")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .frame(width: 26, height: 26)
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
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .ignoresSafeArea(edges: .top)
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

    private func metaChip(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.accentColor.opacity(0.1))
            .foregroundStyle(Color.accentColor)
            .clipShape(Capsule())
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
    }
}
