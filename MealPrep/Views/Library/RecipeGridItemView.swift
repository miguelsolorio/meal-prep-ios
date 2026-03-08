import SwiftUI

struct RecipeGridItemView: View {
    let recipe: Recipe
    let isSelected: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail
            RecipeImageView(url: recipe.imageURL, cornerRadius: 0)
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    if !isSelected {
                        Button(action: onAdd) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(Color.white)
                                .background(Circle().fill(Color.black.opacity(0.35)).padding(2))
                        }
                        .padding(8)
                    }
                }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    if !recipe.displayDuration.isEmpty {
                        Label(recipe.displayDuration, systemImage: "clock")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if !recipe.author.isEmpty && !recipe.displayDuration.isEmpty {
                        Text("·")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    if !recipe.author.isEmpty {
                        Text(recipe.author)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
