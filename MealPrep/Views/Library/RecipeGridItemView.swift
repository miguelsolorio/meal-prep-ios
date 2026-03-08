import SwiftUI

struct RecipeGridItemView: View {
    let recipe: Recipe
    let isSelected: Bool
    let onAdd: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Full-bleed image
            RecipeImageView(url: recipe.imageURL, cornerRadius: 0)
                .frame(maxWidth: .infinity)
                .frame(height: 200)

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Text content
            VStack(alignment: .leading, spacing: 3) {
                Text(recipe.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    if !recipe.displayDuration.isEmpty {
                        Label(recipe.displayDuration, systemImage: "clock")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    if !recipe.author.isEmpty && !recipe.displayDuration.isEmpty {
                        Text("·")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    if !recipe.author.isEmpty {
                        Text(recipe.author)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                }
            }
            .padding(10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
        .overlay(alignment: .topTrailing) {
            if !isSelected {
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4)
                }
                .padding(8)
            }
        }
    }
}
