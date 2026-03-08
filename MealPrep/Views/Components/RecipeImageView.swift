import SwiftUI

struct RecipeImageView: View {
    let url: URL?
    var cornerRadius: CGFloat = 12

    @State private var loadedImage: UIImage?

    var body: some View {
        Group {
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if url != nil {
                Color(.systemGray6)
                    .overlay { ProgressView() }
            } else {
                placeholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .task(id: url) {
            guard let url else { loadedImage = nil; return }
            loadedImage = await ImageCache.shared.image(for: url)
        }
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
