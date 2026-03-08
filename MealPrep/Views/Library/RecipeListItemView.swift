import SwiftUI

struct RecipeListItemView: View {
    let recipe: Recipe
    let isSelected: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if !isSelected {
                Button(action: onAdd) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.secondary)
                }
                .buttonStyle(.plain)
            }

            RecipeImageView(url: recipe.imageURL, cornerRadius: 8)
                .frame(width: 64, height: 64)

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
        }
        .contentShape(Rectangle())
    }
}
