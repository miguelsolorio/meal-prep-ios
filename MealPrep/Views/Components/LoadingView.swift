import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "bag.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.accentColor)

                ProgressView()
                    .scaleEffect(1.2)
            }
        }
    }
}
