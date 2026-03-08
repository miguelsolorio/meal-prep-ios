import SwiftUI

private let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

struct PlanningView: View {
    @EnvironmentObject private var store: RecipeStore

    var body: some View {
        NavigationStack {
            Group {
                if store.selectedRecipeIDs.isEmpty {
                    EmptyStateView(
                        systemImage: "calendar",
                        title: "No Recipes Selected",
                        subtitle: "Add recipes to your shopping list to start planning your week."
                    )
                } else {
                    planList
                }
            }
            .navigationTitle("Planning")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    private var planList: some View {
        List {
            // Unassigned section — always show if there are unassigned recipes
            let unassigned = store.unassignedPlanRecipes
            if !unassigned.isEmpty {
                daySection(title: "Unassigned", day: nil, recipes: unassigned)
            }

            ForEach(0..<7, id: \.self) { day in
                daySection(title: dayNames[day], day: day, recipes: store.recipesForDay(day))
            }
        }
    }

    @ViewBuilder
    private func daySection(title: String, day: Int?, recipes: [Recipe]) -> some View {
        Section(title) {
            ForEach(recipes) { recipe in
                PlanningRowView(recipe: recipe)
                    .contextMenu {
                        moveToDayMenu(for: recipe.id, currentDay: day)
                    }
                    .swipeActions(edge: .trailing) {
                        if day != nil {
                            Button(role: .destructive) {
                                store.moveRecipeToDay(nil, recipeID: recipe.id)
                            } label: {
                                Label("Unassign", systemImage: "xmark")
                            }
                        }
                    }
            }
            .onMove { from, to in
                if let day { store.moveInDay(day, from: from, to: to) }
            }
        }
    }

    @ViewBuilder
    private func moveToDayMenu(for recipeID: UUID, currentDay: Int?) -> some View {
        ForEach(0..<7, id: \.self) { day in
            if day != currentDay {
                Button(dayNames[day]) {
                    store.moveRecipeToDay(day, recipeID: recipeID)
                }
            }
        }
        if currentDay != nil {
            Divider()
            Button("Unassign", role: .destructive) {
                store.moveRecipeToDay(nil, recipeID: recipeID)
            }
        }
    }
}

private struct PlanningRowView: View {
    let recipe: Recipe

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
        }
    }
}
