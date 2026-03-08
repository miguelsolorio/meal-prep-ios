import SwiftUI

struct RecipeImageView: View {
    let url: URL?
    var cornerRadius: CGFloat = 12

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.systemGray6))
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var placeholder: some View {
        ZStack {
            Color(.systemGray6)
            Image(systemName: "fork.knife")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
        }
    }
}
