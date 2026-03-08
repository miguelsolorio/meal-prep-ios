import SwiftUI

struct DayRecipePickerView: View {
    let day: Int
    let dayName: String
    @EnvironmentObject private var store: RecipeStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if store.recipes.isEmpty {
                    EmptyStateView(
                        systemImage: "books.vertical",
                        title: "No Recipes",
                        subtitle: "Import recipes from the Library tab first."
                    )
                } else {
                    List(store.recipes) { recipe in
                        Button {
                            store.addToDay(day, recipeID: recipe.id)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                RecipeImageView(url: recipe.imageURL, cornerRadius: 6)
                                    .frame(width: 44, height: 44)
                                    .clipped()

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(recipe.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                        .lineLimit(2)

                                    if !recipe.displayDuration.isEmpty {
                                        Text(recipe.displayDuration)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle(dayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
