import SwiftUI

struct PlanningView: View {
    @EnvironmentObject private var store: RecipeStore
    @State private var pickingForDay: Int? = nil

    private let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<7, id: \.self) { day in
                    daySection(day)
                }
            }
            .navigationTitle("Planning")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: Binding(
                get: { pickingForDay != nil },
                set: { if !$0 { pickingForDay = nil } }
            )) {
                if let day = pickingForDay {
                    DayRecipePickerView(day: day, dayName: days[day])
                }
            }
        }
    }

    @ViewBuilder
    private func daySection(_ day: Int) -> some View {
        Section(days[day]) {
            let slots = store.recipesForDay(day)

            if slots.isEmpty {
                Text("No recipes planned")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            } else {
                ForEach(slots, id: \.index) { slot in
                    PlanningRowView(recipe: slot.recipe)
                }
                .onMove { store.moveInDay(day, from: $0, to: $1) }
                .onDelete { store.removeFromDay(day, at: $0) }
            }

            Button {
                pickingForDay = day
            } label: {
                Label("Add Recipe", systemImage: "plus")
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
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
