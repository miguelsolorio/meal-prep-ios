import SwiftUI

struct RecipeListItemView: View {
    let recipe: Recipe
    let isSelected: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            RecipeImageView(url: recipe.imageURL, cornerRadius: 10)
                .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                HStack(spacing: 6) {
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

            if !isSelected {
                Button(action: onAdd) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
    }
}
