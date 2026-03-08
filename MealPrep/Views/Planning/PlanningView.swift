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
        }
    }

    private var planList: some View {
        List {
            let unassigned = store.unassignedPlanRecipes
            if !unassigned.isEmpty {
                daySection(title: "Unassigned", day: nil, recipes: unassigned)
            }

            ForEach(0..<7, id: \.self) { day in
                daySection(title: dayNames[day], day: day, recipes: store.recipesForDay(day))
            }
        }
        .environment(\.editMode, .constant(.active))
    }

    @ViewBuilder
    private func daySection(title: String, day: Int?, recipes: [Recipe]) -> some View {
        Section(title) {
            ForEach(recipes) { recipe in
                PlanningRowView(recipe: recipe)
                .contextMenu {
                    moveToDayMenu(for: recipe.id, currentDay: day)
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
            Button(dayNames[day]) {
                store.moveRecipeToDay(day, recipeID: recipeID)
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
