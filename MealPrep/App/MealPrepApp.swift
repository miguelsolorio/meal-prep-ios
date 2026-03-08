import SwiftUI
import SwiftData

@main
struct MealPrepApp: App {
    private let container: ModelContainer
    @StateObject private var store: RecipeStore
    @Environment(\.scenePhase) private var scenePhase

    init() {
        do {
            let container = try ModelContainer(for: Recipe.self)
            self.container = container
            _store = StateObject(wrappedValue: RecipeStore(context: container.mainContext))
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    @State private var isLaunching = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(store)
                    .onOpenURL { url in
                        handleIncomingURL(url)
                    }

                if isLaunching {
                    LoadingView()
                        .transition(.opacity)
                        .task {
                            try? await Task.sleep(for: .milliseconds(800))
                            withAnimation(.easeOut(duration: 0.4)) {
                                isLaunching = false
                            }
                        }
                }
            }
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                checkPendingImport()
            }
        }
    }

    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "mealprep",
              url.host == "import",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let recipeURLString = components.queryItems?.first(where: { $0.name == "url" })?.value
        else { return }
        // Clear pending key so checkPendingImport doesn't double-import
        UserDefaults(suiteName: UserDefaultsKeys.appGroup)?
            .removeObject(forKey: UserDefaultsKeys.pendingImportURL)
        importInBackground(from: recipeURLString)
    }

    private func checkPendingImport() {
        let defaults = UserDefaults(suiteName: UserDefaultsKeys.appGroup)
        guard let urlString = defaults?.string(forKey: UserDefaultsKeys.pendingImportURL) else { return }
        defaults?.removeObject(forKey: UserDefaultsKeys.pendingImportURL)
        importInBackground(from: urlString)
    }

    private func importInBackground(from urlString: String) {
        Task {
            await store.importRecipe(from: urlString)
            if let error = store.importError {
                store.shareImportError = error
                store.importError = nil
            }
        }
    }
}
