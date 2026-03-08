import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject private var store: RecipeStore
    @State private var checkedItems: Set<String> = []
    @State private var groupByDepartment = false
    @State private var newIngredientText = ""
    @State private var showingClearConfirmation = false
    @FocusState private var isAddFieldFocused: Bool

    private var allItems: [ShoppingItem] { store.shoppingListIngredients }
    private var toBuyItems: [ShoppingItem] { allItems.filter { !checkedItems.contains($0.id) } }
    private var inCartItems: [ShoppingItem] { allItems.filter { checkedItems.contains($0.id) } }

    private var selectedRecipes: [Recipe] {
        store.recipes.filter { store.isSelected($0.id) }
    }

    private var activeDepartments: [GroceryDepartment] {
        GroceryDepartment.allCases.filter { dept in
            toBuyItems.contains { $0.department == dept }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if allItems.isEmpty && store.customIngredients.isEmpty {
                    EmptyStateView(
                        systemImage: "cart",
                        title: "No Ingredients",
                        subtitle: "Tap + on recipes in the Library tab to build your shopping list."
                    )
                } else {
                    VStack(spacing: 0) {
                        List {
                            // Add ingredient row
                            Section {
                                HStack {
                                    TextField("Add ingredient…", text: $newIngredientText)
                                        .focused($isAddFieldFocused)
                                        .submitLabel(.done)
                                        .onSubmit(addIngredient)

                                    if !newIngredientText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Button(action: addIngredient) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundStyle(Color.accentColor)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            if groupByDepartment {
                                departmentSections
                            } else {
                                flatSections
                            }
                        }

                        // Bottom buttons
                        VStack(spacing: 8) {
                            Button(role: .destructive) {
                                showingClearConfirmation = true
                            } label: {
                                Text("Clear")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }
                        .padding()
                        .background(Color(.systemGroupedBackground))
                    }
                }
            }
            .navigationTitle("Shopping List")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !allItems.isEmpty {
                        Button {
                            groupByDepartment.toggle()
                        } label: {
                            Image(systemName: groupByDepartment
                                  ? "line.3.horizontal.decrease.circle.fill"
                                  : "line.3.horizontal.decrease.circle")
                        }
                    }
                }
            }
            .alert("Clear Shopping List", isPresented: $showingClearConfirmation) {
                Button("Clear", role: .destructive) {
                    checkedItems.removeAll()
                    store.clearShoppingList()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove all items from your shopping list.")
            }
        }
    }

    // MARK: - Flat sections

    @ViewBuilder
    private var flatSections: some View {
        if !toBuyItems.isEmpty {
            Section("To Buy (\(toBuyItems.count))") {
                ForEach(toBuyItems) { item in
                    ShoppingListRowView(
                        item: item,
                        isChecked: false,
                        onToggle: { checkedItems.insert(item.id) }
                    )
                }
                .onDelete { offsets in deleteCustom(in: toBuyItems, at: offsets) }
            }
        }

        if !inCartItems.isEmpty {
            Section("In Cart (\(inCartItems.count))") {
                ForEach(inCartItems) { item in
                    ShoppingListRowView(
                        item: item,
                        isChecked: true,
                        onToggle: { checkedItems.remove(item.id) }
                    )
                }
                .onDelete { offsets in deleteCustom(in: inCartItems, at: offsets) }
            }
        }
    }

    // MARK: - Department sections

    @ViewBuilder
    private var departmentSections: some View {
        ForEach(activeDepartments) { dept in
            let items = toBuyItems.filter { $0.department == dept }
            Section("\(dept.rawValue) (\(items.count))") {
                ForEach(items) { item in
                    ShoppingListRowView(
                        item: item,
                        isChecked: false,
                        onToggle: { checkedItems.insert(item.id) }
                    )
                }
                .onDelete { offsets in deleteCustom(in: items, at: offsets) }
            }
        }

        if !inCartItems.isEmpty {
            Section("In Cart (\(inCartItems.count))") {
                ForEach(inCartItems) { item in
                    ShoppingListRowView(
                        item: item,
                        isChecked: true,
                        onToggle: { checkedItems.remove(item.id) }
                    )
                }
                .onDelete { offsets in deleteCustom(in: inCartItems, at: offsets) }
            }
        }
    }

    // MARK: - Helpers

    private func addIngredient() {
        store.addCustomIngredient(newIngredientText)
        newIngredientText = ""
    }

    private func deleteCustom(in items: [ShoppingItem], at offsets: IndexSet) {
        let customPrefix = "custom_"
        for index in offsets {
            let item = items[index]
            guard item.id.hasPrefix(customPrefix) else { continue }
            let ingredientID = String(item.id.dropFirst(customPrefix.count))
            store.removeCustomIngredient(id: ingredientID)
            checkedItems.remove(item.id)
        }
    }
}
