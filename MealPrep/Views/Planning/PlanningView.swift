import SwiftUI

private let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

struct PlanningView: View {
    @EnvironmentObject private var store: RecipeStore

    private var selectedRecipes: [Recipe] {
        store.recipes.filter { store.selectedRecipeIDs.contains($0.id) }
    }

    private var unassigned: [Recipe] {
        selectedRecipes.filter { store.mealPlan[$0.id] == nil }
    }

    private func recipesForDay(_ day: Int) -> [Recipe] {
        selectedRecipes.filter { store.mealPlan[$0.id] == day }
    }

    var body: some View {
        NavigationStack {
            Group {
                if selectedRecipes.isEmpty {
                    EmptyStateView(
                        systemImage: "calendar",
                        title: "No Recipes Selected",
                        subtitle: "Add recipes to your shopping list to start planning your week."
                    )
                } else {
                    List {
                        if !unassigned.isEmpty {
                            Section("Unassigned") {
                                ForEach(unassigned) { recipe in
                                    PlanningRowView(recipe: recipe, dayLabel: "Assign day")
                                }
                            }
                        }

                        ForEach(0..<7, id: \.self) { day in
                            let recipes = recipesForDay(day)
                            if !recipes.isEmpty {
                                Section(dayNames[day]) {
                                    ForEach(recipes) { recipe in
                                        PlanningRowView(recipe: recipe, dayLabel: dayNames[day])
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Planning")
        }
    }
}

private struct PlanningRowView: View {
    @EnvironmentObject private var store: RecipeStore
    let recipe: Recipe
    let dayLabel: String

    var body: some View {
        HStack(spacing: 12) {
            RecipeImageView(url: recipe.imageURL, cornerRadius: 6)
                .frame(width: 44, height: 44)
                .clipped()

            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                if !recipe.displayDuration.isEmpty {
                    Text(recipe.displayDuration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Menu {
                ForEach(0..<7, id: \.self) { day in
                    Button {
                        store.assignDay(day, to: recipe.id)
                    } label: {
                        if store.mealPlan[recipe.id] == day {
                            Label(dayNames[day], systemImage: "checkmark")
                        } else {
                            Text(dayNames[day])
                        }
                    }
                }

                if store.mealPlan[recipe.id] != nil {
                    Divider()
                    Button(role: .destructive) {
                        store.assignDay(nil, to: recipe.id)
                    } label: {
                        Label("Unassign", systemImage: "xmark")
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(dayLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .contentShape(Rectangle())
    }
}
