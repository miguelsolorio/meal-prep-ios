import Foundation
import SwiftData
import Combine

// MARK: - ShoppingItem

struct ShoppingItem: Identifiable, Sendable {
    let id: String
    let text: String
    let recipeName: String
    let recipeID: UUID
    var department: GroceryDepartment { GroceryDepartment.classify(text) }
}

// MARK: - CustomIngredient

struct CustomIngredient: Identifiable, Codable, Sendable {
    var id: String
    var text: String
}

// MARK: - RecipeStore

@MainActor
final class RecipeStore: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var selectedRecipeIDs: Set<UUID> = []
    @Published var customIngredients: [CustomIngredient] = []
    @Published var isImporting = false
    @Published var importError: String?
    @Published var searchText = ""
    @Published var filterOptions = FilterOptions()

    private let context: ModelContext
    private let scraper = RecipeScraper()

    init(context: ModelContext) {
        self.context = context
        loadRecipes()
        loadSelectedIDs()
        loadCustomIngredients()
    }

    // MARK: - Persistence

    private func loadRecipes() {
        let descriptor = FetchDescriptor<Recipe>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
        recipes = (try? context.fetch(descriptor)) ?? []
    }

    private func loadSelectedIDs() {
        let strings = UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.selectedRecipeIDs) ?? []
        selectedRecipeIDs = Set(strings.compactMap(UUID.init))
    }

    private func saveSelectedIDs() {
        UserDefaults.standard.set(
            selectedRecipeIDs.map(\.uuidString),
            forKey: UserDefaultsKeys.selectedRecipeIDs
        )
    }

    private func loadCustomIngredients() {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.customIngredients),
              let decoded = try? JSONDecoder().decode([CustomIngredient].self, from: data) else { return }
        customIngredients = decoded
    }

    private func saveCustomIngredients() {
        guard let data = try? JSONEncoder().encode(customIngredients) else { return }
        UserDefaults.standard.set(data, forKey: UserDefaultsKeys.customIngredients)
    }

    // MARK: - Cookie

    var nytCookie: String {
        get { UserDefaults.standard.string(forKey: UserDefaultsKeys.nytCookie) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.nytCookie) }
    }

    // MARK: - Filtering

    var filteredRecipes: [Recipe] {
        var result = recipes

        // Search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { $0.name.lowercased().contains(query) || $0.author.lowercased().contains(query) }
        }

        // Cook time
        if filterOptions.cookTimeFilter != .all {
            result = result.filter { filterOptions.cookTimeFilter.matches(totalMinutes: $0.totalCookMinutes) }
        }

        // Selection
        switch filterOptions.selectionFilter {
        case .selected: result = result.filter { selectedRecipeIDs.contains($0.id) }
        case .unselected: result = result.filter { !selectedRecipeIDs.contains($0.id) }
        case .all: break
        }

        // Sort
        switch filterOptions.sortOrder {
        case .dateAdded: result.sort { $0.dateAdded > $1.dateAdded }
        case .name: result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .cookTime: result.sort { $0.totalCookMinutes < $1.totalCookMinutes }
        }

        return result
    }

    // MARK: - Shopping List

    var shoppingListIngredients: [ShoppingItem] {
        let recipeItems = recipes
            .filter { selectedRecipeIDs.contains($0.id) }
            .flatMap { recipe in
                recipe.ingredients.enumerated().map { index, text in
                    ShoppingItem(
                        id: "\(recipe.id)_\(index)",
                        text: text,
                        recipeName: recipe.name,
                        recipeID: recipe.id
                    )
                }
            }
        let customItems = customIngredients.map { ingredient in
            ShoppingItem(
                id: "custom_\(ingredient.id)",
                text: ingredient.text,
                recipeName: "Custom",
                recipeID: UUID()
            )
        }
        return recipeItems + customItems
    }

    func addCustomIngredient(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        customIngredients.append(CustomIngredient(id: UUID().uuidString, text: trimmed))
        saveCustomIngredients()
    }

    func removeCustomIngredient(id: String) {
        customIngredients.removeAll { $0.id == id }
        saveCustomIngredients()
    }

    func clearCustomIngredients() {
        customIngredients.removeAll()
        saveCustomIngredients()
    }

    func clearShoppingList() {
        selectedRecipeIDs.removeAll()
        saveSelectedIDs()
        customIngredients.removeAll()
        saveCustomIngredients()
    }

    // MARK: - Actions

    func importRecipe(from urlString: String) async {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            importError = ScraperError.invalidURL.errorDescription
            return
        }

        isImporting = true
        importError = nil

        do {
            let scraped = try await scraper.scrape(url: url, cookie: nytCookie)
            let recipe = Recipe(
                name: scraped.name,
                sourceURL: scraped.sourceURL,
                imageURL: scraped.imageURL,
                author: scraped.author,
                ingredients: scraped.ingredients,
                instructions: scraped.instructions,
                rawDuration: scraped.rawDuration,
                servingsText: scraped.servingsText
            )
            context.insert(recipe)
            try context.save()
            loadRecipes()
            importError = nil
        } catch let error as ScraperError {
            importError = error.errorDescription
        } catch {
            importError = error.localizedDescription
        }

        isImporting = false
    }

    func deleteRecipe(_ recipe: Recipe) {
        selectedRecipeIDs.remove(recipe.id)
        saveSelectedIDs()
        context.delete(recipe)
        try? context.save()
        loadRecipes()
    }

    func addToShoppingList(_ id: UUID) {
        selectedRecipeIDs.insert(id)
        saveSelectedIDs()
    }

    func removeFromShoppingList(_ id: UUID) {
        selectedRecipeIDs.remove(id)
        saveSelectedIDs()
    }

    func isSelected(_ id: UUID) -> Bool {
        selectedRecipeIDs.contains(id)
    }
}
